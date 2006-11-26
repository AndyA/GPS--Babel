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

my $info = $babel->get_info();
warn Dumper($info);

ok(1, 'All done');