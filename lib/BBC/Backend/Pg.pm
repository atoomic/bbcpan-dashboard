package BBC::Backend::Pg;

use strict;
use warnings;

use Mojo::Base -base;

use Carp 'croak';

use Mojo::Pg;

use POSIX ();

use Test::More;    # mainly for debugging

has 'pg';          # our pg object


sub new {
    my ( $class, @args ) = @_;
    my $self = $class->SUPER::new( pg => Mojo::Pg->new(@args) );

    my $v = $self->pg->db->dbh->{pg_server_version};
    croak 'PostgreSQL 9.6 or later is required' unless $v >= 90600;

    # run the migration
    $self->pg->auto_migrate(1)->migrations->name('bbc')->from_data;

    return $self;
}

sub select { # kind of delegate - SQL::Abstract
  my ( $self, @args ) = @_;
  return $self->pg->db->select( @args );
}

sub insert { # kind of delegate - SQL::Abstract
  my ( $self, @args ) = @_;
  return $self->pg->db->insert( @args );
}

sub update { # kind of delegate - SQL::Abstract
  my ( $self, @args ) = @_;
  return $self->pg->db->update( @args );
}

sub delete { # kind of delegate - SQL::Abstract
  my ( $self, @args ) = @_;
  return $self->pg->db->delete( @args );
}

sub ping {
  my ($self) = @_;
  return $self->pg->db->ping;
}

sub now {
    my ($self) = @_;

    return $self->pg->db->query('select now() as now')->hash;
}

sub reset_database {
    my ($self) = @_;

    # Reset database
    no warnings;
    return $self->pg->migrations->migrate(0)->migrate;
}

sub create_build {
    my ( $self, $options ) = @_;

    return unless ref $options eq 'HASH';

    $self->repair(1);    # auto repair when adding new build - use force option as we want to run it for every new build

    return $self->pg->db->query(
        "insert into Bbc_builds
       (build_number, state, total_jobs, priority, perl_major, created_by, build_type, updated_at, created_at)
     values (?, ?, ?, ?, ?, ?, ?, now(), now())
     returning id",
        $options->{build_number} // 1,
        $options->{state}        // $self->STATE_PENDING,
        $options->{total_jobs}   // 0,
        $options->{priority}     // $self->PRIORITY_DEFAULT,
        $options->{perl_major}   // 0,
        $options->{ipaddr}       // '127.0.0.1',
        $options->{build_type}
    )->hash->{id};
}

sub repair {
    my ( $self, $force ) = @_;

    return;
}

1;

__DATA__

@@ bbc
-- 1 up
create table if not exists cpan_river (
  id            bigserial not null primary key,

  distribution  text not null,
  state         text not null,
  counter       int not null,
  is_top_1000   boolean not null default FALSE,

  updated_at    timestamp with time zone not null,

  UNIQUE (distribution)
);

create index on cpan_river (distribution);
create index on cpan_river (counter, distribution);
create index on cpan_river (is_top_1000, counter, distribution);

-- 1 down
drop table if exists cpan_river;

-- 2 up
create table if not exists maintainers (
  id            bigserial not null primary key,

  name          text not null,

  UNIQUE (name)
);

create index on maintainers (name);

create table if not exists distro_maintainers (
  distro_id     bigserial not null,
  maintainer_id bigserial not null
);

create index on distro_maintainers (distro_id);
create index on distro_maintainers (maintainer_id);

-- 2 down
drop table if exists maintainers;
drop table if exists distro_maintainers;

