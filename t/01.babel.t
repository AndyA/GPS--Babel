use Test::More;
use GPS::Babel;
use Data::Dumper;
use strict;
use warnings;

my $babel   = GPS::Babel->new();
my $exename = $babel->get_exename();

unless (defined $exename) {
    plan skip_all => "Can't find gpsbabel binary";
    exit;
}

plan tests => 1;

# Because the capabilities of this module depend almost entirely on the
# installed version of gpsbabel it's hard to write a generic set of tests.
# Once I think of a nice way of testing it I'll get back to you. In the
# meantime please feel free to suggest some meaningful tests :)

ok(1, 'All done');