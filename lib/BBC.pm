package BBC;

use strict;
use warnings;

use Mojo::Base -base;
use Mojo::Loader 'load_class';

use Carp 'croak';

use v5.26;

use Test::More;    # for debugging only

has 'backend';

sub new {
    my ( $class, %opts ) = @_;

    my $self = $class->SUPER::new;


    #note explain %opts;
     my $cfg = $opts{cfg};
    my $dsn = $cfg->{dsn} // die "Missing dsn from configuration";
    my $backend = 'Pg';
    my $backend_class = 'BBC::Backend::' . $backend;
    my $e             = load_class $backend_class;
    croak ref $e ? $e : qq{Backend "$backend_class" missing} if $e;
    $self->backend( $backend_class->new($dsn) );

    # my $cfg = $opts{cfg};
    # croak "Missing configuration option" unless defined $cfg;
    # foreach my $required (qw{binary_memory_load_factor max_jobs_per_cpu}) {
    #     croak "Missing $required value" unless defined $cfg->{$required};
    # }

    # # can be improved....
    # $self->upload_directory( $cfg->{upload_directory} );
    # $self->http_base_url( $cfg->{http_base_url} );

    # foreach my $k ( sort qw{alive_timeout idle_timeout repair_frequency binary_memory_load_factor max_jobs_per_cpu webserver_root_path} ) {
    #     next unless exists $cfg->{$k};
    #     $self->backend->can($k)->( $self->backend, $cfg->{$k} );
    # }

    return $self;
}

1;