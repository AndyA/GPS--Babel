use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'GPS::Babel',
    license             => 'perl',
    dist_author         => 'Andy Armstrong <andy@hexten.net>',
    dist_version_from   => 'lib/GPS/Babel.pm',
    requires => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add_to_cleanup      => [ 'GPS-Babel-*' ],
);

$builder->create_build_script();
