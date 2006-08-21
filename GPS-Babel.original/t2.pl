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

my $babel = GPS::Babel->new();

# Read a gpx file. All formats supported by gpsbabel are supported
my $data = $babel->read('name' => 't/small.gpx', 'fmt' => 'gpx');

# Iterate over all points
my $iter = $data->all_points;
# Delete points at high altitude.
while (my $pt = $iter->()) {
    my $ele = $pt->ele;
    if (defined $ele && $ele > 300) {
        $iter->delete_current();
    }
}

# Rename first route    
if ($data->routes->count > 0) {
    $data->route->[0]->name('First Route');
}

# Write as a KML file
$babel->write($data, 'name' => 'out.kml', 'fmt' => 'kml');

# Make new GPS data
my $data2 = GPS::Babel::Data->new();

# Copy waypoints from original data
$data2->waypoints->append($data->waypoints->clone);

# Write as GPX file
$babel->write($data2, 'name' => 'waypoints.gpx', 'fmt' => 'gpx');
