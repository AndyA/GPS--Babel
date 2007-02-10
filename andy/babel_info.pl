#!/usr/bin/perl -w
#
#  babel_info - query GPSBabel capabilities
#
#  Created by Andy Armstrong on 2006-11-27.
#  Copyright (c) 2006 Hexten. All rights reserved.

use strict;
use GPS::Babel;
use Data::Dumper;

$| = 1;

my $babel = GPS::Babel->new();
print Dumper($babel->get_info());
