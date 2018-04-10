#!/usr/bin/env perl

package bbc;

use strict;
use warnings;

use v5.026;

our $VERSION = '0.01';

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use Mojolicious::Lite;
use Mojolicious::Commands;

use BBC ();

our $APP = app();

app->moniker('bbc');
app->plugin('DebugDumperHelper');

push @{ app->commands->namespaces }, 'BBC::Commands';

our $cfg = app->plugin('Config');
helper bbc => sub { state $bbc = BBC->new( cfg => $cfg ) };

# Documentation browser under "/perldoc"
#plugin 'PODRenderer';

get '/' => sub {
  my $c = shift;
  $c->render( template => 'index' );
};

get '/cpan-river' => sub {
  my $c = shift;

  $c->stash( cpan_river => $c->bbc->get_cpan_river( limit => 100 ) );
  $c->render( template => 'cpan-river' );	
};

get '/view-reports/:distro' => sub {
	my $c = shift;

	$c->render( template => 'view-report' );	
};

get '/view-reports' => sub {
	my $c = shift;

	$c->redirect_to('/');
};

app->start;
__DATA__

@@ xxindex.html.ep
% layout 'default';
% title 'Welcome';
<h1>Welcome to the Mojolicious real-time web framework!</h1>
To learn more, you can browse through the documentation
<%= link_to 'here' => '/perldoc' %>.

@@ xxlayouts/default.html.ep
<!DOCTYPE html>
<html>
  <head><title><%= title %></title></head>
  <body><%= content %></body>
</html>
