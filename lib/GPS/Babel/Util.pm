package GPS::Babel::Util;

use warnings;
use strict;
use Carp;
use Scalar::Util qw(blessed);

use Exporter;
our @ISA = qw(Exporter);
our @EXPORT_OK = qw(clone_object gc_distance heading);

my $EARTH_RADIUS = 6378137.0;
my $PI           = 4 * atan2(1, 1);
my $DEG_TO_RAD   = $PI / 180.0;
my $RAD_TO_DEG   = 180.0 / $PI;

sub massage_coordinates {
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

# Utility function: clone an arbitrary object. Not a method
sub clone_object {
    my $obj = shift;
    return $obj
        unless ref $obj;
    return $obj->clone()
        if blessed($obj) && $obj->can('clone');
    return $obj;
}

sub deg {
    return map { $_ * $RAD_TO_DEG } @_;
}

sub rad {
    return map { $_ * $DEG_TO_RAD } @_;
}

# From
#  http://perldoc.perl.org/functions/sin.html
sub asin {
    atan2($_[0], sqrt(1 - $_[0] * $_[0]))
}

sub gc_distance {
    @_ = massage_coordinates(@_);

    my $dist = 0;
    my ($lat1, $lon1);
    while (my $pt = shift) {
        my ($lat2, $lon2) = rad($pt->[0], $pt->[1]);
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
            $dist += 2.0 * asin($res);
        }
        ($lat1, $lon1) = ($lat2, $lon2);
    }

    return $dist * $EARTH_RADIUS;
}

sub heading {
    @_ = massage_coordinates(@_);

    return unless @_;

    # Compute heading from first point to last
    my ($lat1, $lon1) = rad($_[ 0]->[0], $_[ 0]->[1]);
    my ($lat2, $lon2) = rad($_[-1]->[0], $_[-1]->[1]);

    return if $lat1 == $lat2 &&
              $lon1 == $lon2;

    my $dlon    = $lon1 - $lon2;
    my $clat2   = cos($lat2);

    my $heading = deg(atan2(sin($dlon) * $clat2,
                            cos($lat1) * sin($lat2)
                             - sin($lat1) * $clat2 * cos($dlon)));

    $heading -= 360.0
        if $heading >= 360.0;

    return $heading;
}

1;
__END__

=head1 NAME

GPS::Babel - [One line description of module's purpose here]


=head1 VERSION

This document describes GPS::Babel version 0.0.1


=head1 SYNOPSIS

    use GPS::Babel;

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.


=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.


=head1 INTERFACE

=for author to fill in:
    Write a separate section listing the public components of the modules
    interface. These normally consist of either subroutines that may be
    exported, or methods that may be called on objects belonging to the
    classes provided by the module.


=head1 DIAGNOSTICS

=for author to fill in:
    List every single error and warning message that the module can
    generate (even the ones that will "never happen"), with a full
    explanation of each problem, one or more likely causes, and any
    suggested remedies.

=over

=item C<< Error message here, perhaps with %s placeholders >>

[Description of error here]

=item C<< Another error message here >>

[Description of error here]

[Et cetera, et cetera]

=back


=head1 CONFIGURATION AND ENVIRONMENT

=for author to fill in:
    A full explanation of any configuration system(s) used by the
    module, including the names and locations of any configuration
    files, and the meaning of any environment variables or properties
    that can be set. These descriptions must also include details of any
    configuration language used.

GPS::Babel requires no configuration files or environment variables.


=head1 DEPENDENCIES

=for author to fill in:
    A list of all the other modules that this module relies upon,
    including any restrictions on versions, and an indication whether
    the module is part of the standard Perl distribution, part of the
    module's distribution, or must be installed separately. ]

None.


=head1 INCOMPATIBILITIES

=for author to fill in:
    A list of any modules that this module cannot be used in conjunction
    with. This may be due to name conflicts in the interface, or
    competition for system or program resources, or due to internal
    limitations of Perl (for example, many modules that use source code
    filters are mutually incompatible).

None reported.


=head1 BUGS AND LIMITATIONS

=for author to fill in:
    A list of known problems with the module, together with some
    indication Whether they are likely to be fixed in an upcoming
    release. Also a list of restrictions on the features the module
    does provide: data types that cannot be handled, performance issues
    and the circumstances in which they may arise, practical
    limitations on the size of data sets, special cases that are not
    (yet) handled, etc.

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
