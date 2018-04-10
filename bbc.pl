#!/usr/bin/env perl

package bbc;

use strict;
use warnings;

our $VERSION = '0.01';

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/lib" }

use Mojolicious::Lite;
use Mojolicious::Commands;

# Documentation browser under "/perldoc"
#plugin 'PODRenderer';

get '/' => sub {
  my $c = shift;
  $c->render( template => 'index' );
};

get '/cpan-river' => sub {
  my $c = shift;
  $c->render( template => 'cpan-river' );	
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
