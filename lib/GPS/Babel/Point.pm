package GPS::Babel::Point;

use warnings;
use strict;
use Carp;
use GPS::Babel::Node;
use GPS::Babel::Iterator;

our @ISA = qw(GPS::Babel::Node);

sub new {
    my ($proto, @args) = @_;

    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@args);
	return bless $self, $class;
}

sub all_points {
    my ($self) = @_;
    return GPS::Babel::Iterator->new_for_object($self);
}

1;
__END__

=head1 NAME

GPS::Babel::Point - Represents a waypoint, route point or track point in GPS data.

=head1 VERSION

This document describes GPS::Babel::Point version 0.0.3

=head1 SYNOPSIS

    use GPS::Babel::Point;

=head1 DESCRIPTION

Wraps a single point.

=head1 CONSTRUCTORS

=over

=item new([attribute list])

Construct a new GPS::Babel::Point optionally providing values for attributes.

    my $point = GPS::Babel::Point->new(lat => 57, lon => -2, ele => 437);

=back

=head1 METHODS

=over

=item all_points

In common with all other data objects in the GPS::Babel hierarchy all_points returns
a GPS::Babel::Iterator that iterates over all the points the object contains. In the
case of a GPS::Babel::Point the returned iterator will return only the point itself.

=back

In addition to the explictly provided all_points method AUTOLOADed accessors
are provided for a number of attributes. See L<GPS::Babel::Node|GPS::Babel::Node>
for more details of the attribute mechanism. In brief you can either access attributes
explicitly using the attr method:

    $pt->attr(ele => $the_elevation);       # set attribute
    $altitude = $pt->attr('ele');           # get attribute

or by using automatically generated methods named after the attribute name:

    $pt->ele($the_elevation)                # set attribute
    $altitude = $pt->ele;

The former approach allows the attribute name to be computed at runtime and allows
access to any (possible future) attributes that are hidden by a regular method name.
The latter approach offers cleaner syntax.

The attributes that exist after reading a GPS data file will depend on the content
of the file. The only mandatory attributes are C<lat> and C<lon>.

=over

=item lat

=item lon

=back

In addition some or all of the following attributes may be present and can be set.

=over

=item cmt

=item course

=item desc

=item ele

=item extensions

=item fix

=item hdop

=item name

=item pdop

=item sat

=item speed

=item sym

=item time

=item type

=item url

=item vdop

=back

Depending on type of the GPS data file you read attributes not listed above may
also be present; to find all attribute names used for a given file use something
like this:

    #!/usr/bin/perl -w
    use strict;
    use GPS::Babel;

    $| = 1;

    my $babel = GPS::Babel->new();
    my $data  = $babel->read('name' => 'sample.gpx', 'fmt' => 'gpx');
    my %found = ( );

    my $iter = $data->all_points;
    while (my $pt = $iter->()) {
        $found{$_}++ for ($pt->attr_names);
    }

    print "$_\n" for sort keys %found;

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
