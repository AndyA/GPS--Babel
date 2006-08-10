package GPS::Babel::Util;

use warnings;
use strict;
use Carp;
use Scalar::Util qw(blessed);

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(_clone_object gc_distance heading);

my $EARTH_RADIUS = 6378137.0;
my $PI           = 4 * atan2(1, 1);
my $DEG_TO_RAD   = $PI / 180.0;
my $RAD_TO_DEG   = 180.0 / $PI;

sub _massage_coordinates {
    my @a = ( );
    while (@_) {
        if (@_ >= 2 && !ref($_[0]) && !ref($_[1])) {
            # Two scalars - must be lat, lon
            push @a, [ $_[0], $_[1] ];
            splice @_, 0, 2;
        } elsif (my $ref = ref($_[0])) {
            if ($ref eq 'ARRAY') {
                my $ar = shift;
                push @a, [ $ar->[0], $ar->[1] ];
            } elsif ($ref eq 'HASH') {
                my $hs = shift;
                push @a, [ $hs->{lat}, $hs->{lon} ];
            } elsif (blessed($_[0]) && $_[0]->isa('GPS::Babel::Point')) {
                my $pt = shift;
                push @a, [ $pt->attr('lat'), $pt->attr('lon') ];
            } else {
                croak "Can't get a position from a $ref";
            }
        } else {
            croak "Can't parse args as coordinates";
        }
    }
    return @a;
}

sub _deg {
    return map { $_ * $RAD_TO_DEG } @_;
}

sub _rad {
    return map { $_ * $DEG_TO_RAD } @_;
}

# From
#  http://perldoc.perl.org/functions/sin.html
sub _asin {
    atan2($_[0], sqrt(1 - $_[0] * $_[0]))
}

sub gc_distance {
    @_ = _massage_coordinates(@_);

    my $dist = 0;
    my ($lat1, $lon1);
    while (my $pt = shift) {
        my ($lat2, $lon2) = _rad($pt->[0], $pt->[1]);
        if (defined $lat1) {
            my $sdlat = sin(($lat1 - $lat2) / 2.0);
            my $sdlon = sin(($lon1 - $lon2) / 2.0);
            my $res   = sqrt($sdlat * $sdlat
                             + cos($lat1) * cos($lat2) * $sdlon * $sdlon);
            if ($res > 1.0) {
                $res = 1.0;
            } elsif ($res < -1.0) {
                $res = -1.0;
            }
            $dist += 2.0 * _asin($res);
        }
        ($lat1, $lon1) = ($lat2, $lon2);
    }

    return $dist * $EARTH_RADIUS;
}

sub heading {
    @_ = _massage_coordinates(@_);

    return unless @_;

    # Compute heading from first point to last
    my ($lat1, $lon1) = _rad($_[ 0]->[0], $_[ 0]->[1]);
    my ($lat2, $lon2) = _rad($_[-1]->[0], $_[-1]->[1]);

    return if $lat1 == $lat2 &&
              $lon1 == $lon2;

    my $dlon    = $lon1 - $lon2;
    my $clat2   = cos($lat2);

    my $heading = _deg(atan2(sin($dlon) * $clat2,
                             cos($lat1) * sin($lat2)
                             - sin($lat1) * $clat2 * cos($dlon)));

    $heading -= 360.0 if $heading >= 360.0;

    return $heading;
}

1;
__END__

=head1 NAME

GPS::Babel::Util - Various utility functions for use with L<GPS::Babel|GPS::Babel>

=head1 VERSION

This document describes GPS::Babel::Util version 0.0.2

=head1 SYNOPSIS

    use GPS::Babel:Util qw(gc_distance heading);

    my $distance = gc_distance($point1, $point2);
    my $track_length = gc_distance(@points);

    my $direction_home = heading($here, $home);

=head1 DESCRIPTION

When working with geographical locations it's often useful to be able to measure the
approximate distance between points - or the length of tracks - and to determine the
heading from one point to another.

GPS::Babel::Util provides functions (gc_distance and heading) that perform these
calculations. Their interface can be used either with GPS::Babel data or with discrete
latitude and longitude values in a number of formats.

=head1 INTERFACE

=over

=item gc_distance(point ...)

Compute the Great Circle distance between two or more points. For more information about
GC distances (and in particular how they differ from on-the-ground-distances) see:

L<http://en.wikipedia.org/wiki/Great-circle_distance>

If more than two points are supplied the distance will be the total of the distances
between all the points - i.e. the length of the route they describe. Each point may be
specified as

=over

=item a pair of scalars: latitude, longitude

    my $distance = gc_distance(57, -2, 56, -1);

=item a reference to a two element array containing latitude, longitude

    my @HOME = ( 57, -2 );
    my $distance = gc_distance(\@HOME, [56, -1]);

=item a reference to a hash with keys 'lat' and 'lon'

    my %HOME = ( lat => 57, lon => -2 );
    my $distance = gc_distance(\%HOME, 56, -1);

=item a reference to a GPS::Babel::Point

    my $home = GPS::Babel::Point->new(lat => 57, lon -2);
    my $distance = gc_distance($home, [56, -1]);

=back

All of the above calls to gc_distance are equivalent.

=item heading($point, $point)

Compute the heading in degrees from one point to another. The returned value is the
compass heading you would take from the first point to pass through the second.

If the heading can't be computed (perhaps because the two points are the same) undef
will be returned.

Coordinates may be passed in the same formats that gc_distance supports.

=back

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-gps-babel@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2006, Andy Armstrong C<< <andy@hexten.net> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
