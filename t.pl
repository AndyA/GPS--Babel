#!/usr/bin/perl -w
#
#  t
#
#  Created by Andy Armstrong on 2006-07-17.
#  Copyright (c) 2006 Hexten. All rights reserved.

use strict;
use lib qw(lib);
use GPS::Babel;
use GPS::Babel::Data;
use Data::Dumper;

$| = 1;

my $babel = GPS::Babel->new();

my $data  = $babel->read('name' => 't/all.gpx', 'fmt' => 'gpx');

print Dumper($data);
