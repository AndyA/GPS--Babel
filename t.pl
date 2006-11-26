#!/usr/bin/perl -w

use strict;
use lib qw(lib);
use GPS::Babel;
use Data::Dumper;

my $babel = GPS::Babel->new();
print "Using ", $babel->version(), "\n";

#print Dumper($babel->get_info()->{for_ext});
#$babel->direct(qw(spong));

$babel->convert('reference/compegps.wpt', 'out.gpx', { all => 1 });
