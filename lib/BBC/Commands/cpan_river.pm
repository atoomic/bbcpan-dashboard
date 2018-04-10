# Lowercase command name
package BBC::Commands::cpan_river;

use strict;
use warnings;

use Test::More;    # for debugging
use Mojo::Base 'Mojolicious::Command';

use Getopt::Long qw(GetOptionsFromArray);

# Short description
has description => 'update cpan river list';

# Usage message from SYNOPSIS
has usage => sub { shift->extract_usage };

has dry_run => sub { 0 };


sub run {
    my ( $self, @args ) = @_;

    my ( $dry_run, $force, $csv_file, $limit, $debug );
    GetOptionsFromArray( 
        \@args, 
        # 'dry-run', \$dry_run, # not implemented yet
        'force', \$force,
        'debug', \$debug,
        'csv=s', \$csv_file,
        'limit=i', \$limit,
    );

    die qq[Missing --csv argument\n] unless $csv_file;
    die qq[Cannot find csv file $csv_file\n] unless -e $csv_file;
    
    $self->dry_run($dry_run);
    note "dry-run mode enable" if $self->dry_run;

    my $backend = $self->app->bbc->backend;
    die qq[Cannot ping db\n] unless $backend->ping;

    note "Deleting tables...";

    $backend->delete( 'cpan_river' );
    $backend->delete( 'maintainers' );
    $backend->delete( 'distro_maintainers' );
    
    my $cache_authors = {}; # cache for authors

    note qq[Reading CSV file];
    open( my $fh, '<', $csv_file ) or die $!;
    my $c = 0;
    while ( my $line = readline($fh) ) {
        ++$c;
        note $line if $debug;
        my @row = split(/\s*,\s*/, $line );

        if ( $c == 1 ) {
            die "Invalid csv format: ", explain \@row unless $row[0] eq 'count'
                && $row[1] eq 'distribution'
                && $row[2] eq 'core_upstream_status'
                && $row[3] eq 'maintainers';
            next;
        }
        
        my ( $count, $distribution, $state, $maintainers_str ) = @row;
        $maintainers_str //= '';
        $state //= '';
        next unless defined $distribution;

        # insert the distro
        $backend->insert('cpan_river', 
            { distribution => $distribution, state => $state, counter => $count, updated_at => \"now()" } 
        );
        my $dist_id = $backend->select( 'cpan_river', 'id', { distribution => $distribution }, { limit => 1 } )->array->[0];

        my @maintainers = split( /\s+/, $maintainers_str );
        foreach my $maint ( @maintainers ) {
            if ( ! $cache_authors->{$maint} ) { 
                $backend->insert('maintainers', { name => $maint }, {on_conflict => undef} );            
                $cache_authors->{$maint} = $backend->select( 'maintainers', 'id', { name => $maint }, { limit => 1 } )->array->[0];
            }
            $backend->insert('distro_maintainers', 
                { distro_id => $dist_id, maintainer_id => $cache_authors->{$maint} } 
            );
        }

        note explain [ $count, $distribution, $state, $maintainers_str ] if $debug;
        last if $limit && $c > $limit;
    }

    note qq[Mark the top 1000];

    $backend->pg->db->query( "update cpan_river set is_top_1000=true 
        where id in
        ( select id from cpan_river order by counter desc limit 1000 )
        ");

    note qq[Done.\n];

    return;
}

1;

=head1 SYNOPSIS

  Usage: APPLICATION cpan_river --csv=file.csv

Clear and restore database for cpan river.

  Options:

    --csv=FILE  load CSV file

=cut