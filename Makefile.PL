use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    (MM->can('signature_target') ? (SIGN => 1) : ()),
    NAME                => 'GPS::Babel',
    AUTHOR              => 'Andy Armstrong <andy@hexten.net>',
    VERSION_FROM        => 'lib/GPS/Babel.pm',
    ABSTRACT_FROM       => 'lib/GPS/Babel.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'    => 0,
        'version'       => 0,
        'Geo::Gpx'      => '0.15',
        'File::Which'   => 0,
        'Class::Std'    => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'GPS-Babel-*' },
);
