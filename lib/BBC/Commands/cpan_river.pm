# Lowercase command name
package BBC::Commands::cpan_river;

use strict;
use warnings;

use Test::More;    # for debugging
use Mojo::Base 'Mojolicious::Command';

# Short description
has description => 'update cpan river list';

# Usage message from SYNOPSIS
has usage => sub { shift->extract_usage };

has dry_run => sub { 0 };


sub run {
    my ( $self, @args ) = @_;

    my $dry_run = grep { $_ =~ qr{dry-run} } @args;
    my $force   = grep { $_ =~ qr{force} } @args;

    my $backend = $self->app->bbc->backend;
    
    $self->dry_run($dry_run);
    note "dry-run mode enable" if $self->dry_run;

    die qq[Cannot ping db\n] unless $backend->ping;

    note "Deleting tables...";
    $backend->delete( 'cpan_river' );
    $backend->delete( 'maintainers' );
    $backend->delete( 'distro_maintainers' );
    
    note "Inserting new values";

    $backend->insert('cpan_river', { distribution => 'test', state => "xxx", counter => 1234, updated_at => \"now()" } );

    note explain $backend->select( 'cpan_river' )->hash;

    return;
}

1;

=head1 SYNOPSIS

  Usage: APPLICATION cpan_river file.csv

  Options:

    --dry-run to do not unlink the binaries

=cut