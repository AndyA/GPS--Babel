#!/usr/bin/perl -w

use strict;
use lib qw(lib);
use Geo::Gpx;
use GPS::Babel;
use Data::Dumper;

my $babel = GPS::Babel->new();
#print "Using ", $babel->version(), "\n";

print Dumper($babel->get_info());
#$babel->direct(qw(spong));

#$babel->convert('reference/compegps.wpt', 'out.gpx');

#my $gpx = $babel->read('reference/compegps.wpt', { in_format => 'compegps' });
#my $gpx = Geo::Gpx->new(input => 'test.gpx');
#print Dumper($gpx);
#$babel->write('test.wpt', $gpx);