use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'GPS::Babel',
    sign                => 1,
    license             => 'perl',
    dist_author         => 'Andy Armstrong <andy@hexten.net>',
    dist_version_from   => 'lib/GPS/Babel.pm',
    requires => {
        'Test::More'    => 0,
        'version'       => 0,
        'Geo::Gpx'      => 0,
        'File::Which'   => 0,
        'Class::Std'    => 0,
    },
    add_to_cleanup      => [ 'GPS-Babel-*' ],
);

$builder->create_build_script();
