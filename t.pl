#!/usr/bin/perl -w
#
#  Created by Andy Armstrong on 2006-07-17.
#  Copyright (c) 2006 Hexten. All rights reserved.

use strict;
use lib qw(lib);
use GPS::Babel;
use GPS::Babel::Iterator;
use GPS::Babel::Point;
use Data::Dumper;

$| = 1;

# We only need a single GPS::Babel object
my $babel = GPS::Babel->new();

# Read a gpx file. All formats supported by gpsbabel are supported
my $data  = $babel->read('name' => 't/small.gpx', 'fmt' => 'gpx');

my $dup   = $data->clone;

# Rename all points in the data
my $point = 1;
my $dummy = GPS::Babel::Point->new(lat => 1, lon => 1, name => 'Dummy');
my $iter = $data->all_points;
while (my $pt = $iter->()) {
    $pt->name(sprintf("PT%04d", $point++));
    #my $ctx = $iter->context || '(undef)';
    #print "Context: $ctx\n";
    my $cmt = $pt->cmt || '';
    if ($cmt =~ /HWY/) {
        $iter->replace_current($dummy->clone);
    }
}

# Add a new waypoint
$data->waypoints->add(GPS::Babel::Point->new(lat => 57.3, lon => -2.0));
my %pt = ( lat => 54.3562, lon => 0.7837, name => 'where?' );
# Add with a hash ref
$data->waypoints->add(GPS::Babel::Point->new(\%pt));
# Add as a clone of an existing object
$data->waypoints->add(GPS::Babel::Point->new($data->route->[0]->item->[0]));

# Duplicate the first route
if ($data->routes->count > 0) {
    my $nroute = $data->route->[0]->clone;
    $data->routes->add($nroute);
}

#print Dumper($data);

# Add all the waypoints to the first route
$data->routes->[0]->append($data->waypoints->clone);

# Write the data to a new file. All gpsbabel formats are supported
$babel->write($data, 'name' => 'out.gpx', 'fmt' => 'gpx');

# A simple function that selects points close to a specified
# latitude, longitude
my $near = sub {
    my $pt = $_;
    my $lat = $pt->lat;
    my $lon = $pt->lon;
    my $dx = $lat - 57;
    my $dy = $lon + 2;
    return ($dx * $dx + $dy * $dy) < 5;
};

#Iterate various subsets of the points in the data
iterate($data->all_points, 'All points');
iterate($data->waypoints->all_points, 'All waypoints');
iterate($data->routes->all_points, 'All routes');
iterate($data->route->[0]->all_points, 'First route');
iterate($data->all_points->with_grep($near), 'Near home');
iterate($data->all_points->with_grep(sub { !$near->() }), 'Not near home');
iterate($data->route->[0]->item->[0]->all_points, 'One point');

# Create a new data file from scratch
$data = GPS::Babel::Data->new();
# Add two waypoints
$data->waypoints->add(GPS::Babel::Point->new(lat => 54.7873, lon => -1.6347, name => 'Point 1'));
$data->waypoints->add(GPS::Babel::Point->new(lat => 53.8812, lon => -1.2337, name => 'Point 2'));
# Create a new route
my $route = GPS::Babel::Node->new(name => 'My Route');
# Add two points to route
$route->add(GPS::Babel::Point->new(lat => 51.7233, lon => -1.9873, name => 'Route Point 1'));
$route->add(GPS::Babel::Point->new(lat => 52.7221, lon => -2.0156, name => 'Route Point 2'));
# Add route to data
$data->routes->append($route);

iterate($data->all_points, 'All points in new data');
iterate($data->routes->all_points, 'Routes in new data');
my $it_both = GPS::Babel::Iterator->new_with_iterators($data->all_points, $data->routes->all_points);
iterate($it_both, 'Both with duplicates');
my $it_unique = GPS::Babel::Iterator->new_with_iterators($data->all_points, $data->routes->all_points)->unique;
iterate($it_unique, 'Both without duplicates');

# Append all route points as waypoints
$data->waypoints->append($data->routes->all_points);

iterate($data->all_nodes, 'All nodes');

# Write new data - again all gpsbabel formats are supported
$babel->write($data, 'name' => 'synth.gpx', 'fmt' => 'gpx');

#print Dumper($dup);

sub iterate {
    my ($iter, $capn) = @_;
    print "\n$capn\n";
    while (my $pt = $iter->()) {
        my $name    = $pt->name || '(no name)';
        my $next = $iter->next;
        my $prev = $iter->previous;
        my $nn = ($next && $next->name) || '(no name)';
        my $pn = ($prev && $prev->name) || '(no name)';
        my @loc = ( $pt->lat || 0, $pt->lon || 0 );
        print "$pt $name, ", join(', ', @loc), " p=$pn, n=$nn\n";
    }
}

