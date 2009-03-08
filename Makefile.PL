use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
  ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
  license( 'perl' ),
  NAME          => 'GPS::Babel',
  AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
  VERSION_FROM  => 'lib/GPS/Babel.pm',
  ABSTRACT_FROM => 'lib/GPS/Babel.pm',
  PL_FILES      => {},
  PREREQ_PM     => {
    'Test::More'  => 0,
    'Geo::Gpx'    => '0.15',
    'File::Which' => 0,
  },
  dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES    => 'GPS-Babel-*' },
);

sub license {
  my $lic = shift;
  local $^W = 0;    # Silence warning about non-numeric version
  return
   unless $ExtUtils::MakeMaker::VERSION >= '6.31';
  return ( LICENSE => $lic );
}
