use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'GPS::Babel',
    AUTHOR              => 'Andy Armstrong <andy@hexten.net>',
    VERSION_FROM        => 'lib/GPS/Babel.pm',
    ABSTRACT_FROM       => 'lib/GPS/Babel.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'        => 0,
        'version'           => 0,
        'XML::Parser'       => 0,
        'XML::Generator'    => 0,
        'File::Which'       => 0,
        'IO::Pipe'          => 0
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'GPS-Babel-*' },
);
