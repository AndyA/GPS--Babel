package GPS::Babel::Collection;

=head1 NAME

GPS::Babel::Collection - Collections of points for L<GPS::Babel|GPS::Babel>.

=head1 VERSION

This document describes GPS::Babel::Collection version 0.0.2

=head1 SYNOPSIS

    use GPS::Babel;

    my $babel = GPS::Babel->new();

    # Read a gpx file. All formats supported by gpsbabel are supported
    my $data = $babel->read('name' => 'raw.gpx', 'fmt' => 'gpx');

    # Rename first route. Collections behave much like arrays (which they are)
    if ($data->routes->count > 0) {
        $data->route->[0]->name('First Route');
    }

    # Copy waypoints from original data. Collections support convenience
    # methods such as append() and clone()
    $data2->waypoints->append($data->waypoints->clone);

=head1 DESCRIPTION

L<GPS::Babel|GPS::Babel> provides a simple interface to gpsbabel
(L<http://gpsbabel.org/>). This class is used to hold collections of
points (and sometimes other collections). GPS::Babel::Collection objects
behave like a normal array but have a number of convenience methods that
simplify the manipulation of GPS data sets.

In addition to the methods described here GPS::Babel::Collection
inherits a number of methods from
L<GPS::Babel::Object|GPS::Babel::Object>.

=cut

use warnings;
use strict;
use Carp;
use GPS::Babel::Node;
use GPS::Babel::Object;
use GPS::Babel::Util;
use GPS::Babel::Iterator;
use Scalar::Util qw(blessed);

our @ISA = qw(GPS::Babel::Object);

=head1 CONSTRUCTORS

=over

=item new( exe => exename )

Constructs a new object. Any arguments to the constructor are added to
the array.

=cut

sub new {
    my ($proto, @args) = @_;
    my $class = ref($proto) || $proto;
    my $self = bless [ ], $class;
    $self->add($_) for @args;
	return $self;
}

=back

=head1 METHODS

=over

=item count

Returns the number of elements in the collection. Equivalent to
C<scalar(@{$collecion})>.

=cut

sub count {
    my $self = shift;
    return scalar(@{$self});
}

=item emptyhttp://www.google.co.uk/search?hs=rbQ&hl=en&client=firefox&rls=org.mozilla%3Aen-US%3Aunofficial&q=ngi+belgium&btnG=Search&meta=

Removes all elements from the collection. Equivalent to C<splice @{$self}>.

=cut

sub empty {
    my $self = shift;
    splice @{$self};
}

sub clone {
    my $self = shift;
    my $new  = [ ];
    for (@{$self}) {
        push @{$new}, GPS::Babel::Util::clone_object($_);
    }
    return bless $new, ref($self);
}

sub add {
    my $self = shift;
    push @{$self}, @_;
}

sub all_points {
    my $self = shift;
    return GPS::Babel::Iterator->new_for_array($self);
}

sub write_as_gpx {
    my ($self, $fh, $indent, $path) = @_;
    for my $nd (@{$self}) {
        $nd->write_as_gpx($fh, $indent, $path);
    }
}

sub as_array {
    my $self = shift;
    return @{$self};
}

1;
__END__

=back

=head1 SEE ALSO

L<GPS::Babel::Object|GPS::Babel::Object>, L<GPS::Babel|GPS::Babel>

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
