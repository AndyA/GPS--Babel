package GPS::Babel::Index::ByTime;

use warnings;
use strict;
use Carp;
use Scalar::Util qw(blessed);
use List::Util qw(min);

use GPS::Babel::Point;
use GPS::Babel::Util qw(gc_distance);

sub new {
    my ($proto, $obj) = @_;
    my $class = ref($proto) || $proto;

    croak "Need an object"
        unless blessed $obj;

    unless ($obj->isa('GPS::Babel::Iterator')) {
        croak "Object must be an iterator or support all_points method."
            unless $obj->can('all_points');
        $obj = $obj->all_points;
    }

    # Sort all the points that have time fields. We don't discard
    # the cached time field because it'll speed things up later
    my @pts = sort { $a->[1] <=> $b->[1] }
              grep { defined $_->[1] && defined $_->[2] && defined $_->[3] }
              map  { [ $_, $_->attr('time'), $_->attr('lat'), $_->attr('lon') ] } $obj->as_array;

    my $self = {
        points  => \@pts,
    };

    return bless $self, $class;
}

# Returns the index of the first point with time >= the supplied time
sub _search {
    my $self = shift;
    my $time = shift;

    my $pts  = $self->{points};

    my ($lo, $mid, $hi) = ( 0, 0, scalar @{$pts}-1 );

    TRY:
    while ($lo <= $hi) {
        $mid = int(($lo + $hi) / 2);
        my $cmp = $pts->[$mid]->[1] <=> $time;
        if ($cmp < 0) {
            $lo = $mid + 1;
        } elsif ($cmp > 0) {
            $hi = $mid - 1;
        } else {
            last TRY;
        }
    }

    while ($mid < scalar @{$pts} && $pts->[$mid]->[1] < $time) {
        $mid++;
    }

    return ($mid < scalar @{$pts}) ? $mid : undef;
}

sub _interp {
    my ($lo, $mid, $hi, $val1, $val2) = @_;
    confess "$lo <= $mid <= $hi !"
        unless $lo <= $mid && $mid <= $hi;
    my $scale = $hi  - $lo;
    my $posn  = $mid - $lo;
    return ($val1 * ($scale - $posn) + $val2 * $posn) / $scale;
}

# Return a point that represents the position at the specified time. In an
# array context returns the point, a flag that indicates whether the
# returned point is synthetic and the distance in metres to the nearest real
# point. If the time can't be matched the returned point will be undef.
sub lookup {
    my $self        = shift;
    my $time        = shift;    # Time to return location for
    my $max_dist    = shift;    # Optional maximum distance to
                                # nearest real point.

    my $pos = $self->_search($time);
    if (defined $pos) {
        my $pts = $self->{points};

        if ($pts->[$pos]->[1] == $time) {
            # Exact match - just return the point
            my $pt = $pts->[$pos]->[0];
            return wantarray ? ( $pt, 0, 0 ) : $pt;
        }

        # If we're at the first point we can't
        # interpolate with anything.
        return if $pos == 0;

        my ($p1, $p2) = @$pts[$pos-1, $pos];

        # Linear interpolation between nearest points
        my $lat = _interp($p1->[1], $time, $p2->[1], $p1->[2], $p2->[2]);
        my $lon = _interp($p1->[1], $time, $p2->[1], $p1->[3], $p2->[3]);

        my $nearest = 0;
        # Compute nearest if we need to return it or check proximity
        if (wantarray || defined $max_dist) {
            $nearest = min(gc_distance($lat, $lon, $p1->[0]),
                           gc_distance($lat, $lon, $p2->[0]));

            # Nearest point out of range?
            return if defined $max_dist && $nearest > $max_dist;
        }

        # Make a new point
        my $pt = GPS::Babel::Point->new(time => $time);
        $pt->attr(lat => $lat);
        $pt->attr(lon => $lon);
        my ($e1, $e2) = map { $_->[0]->attr('ele') } ($p1, $p2);

        if (defined $e1 && defined $e2) {
            $pt->attr('ele', _interp($p1->[1], $time, $p2->[1], $e1, $e2));
        }

        # Return a synthetic point
        return wantarray ? ( $pt, 1, $nearest ) : $pt;
    }

    return;
}

sub time_range {
    my $self = shift;
    my $pts  = $self->{points};
    return unless scalar @{$pts};
    return ( $pts->[0]->[1], $pts->[-1]->[1] );
}

1;
__END__

=head1 NAME

GPS::Babel - [One line description of module's purpose here]


=head1 VERSION

This document describes GPS::Babel version 0.0.2

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

=head1 CONSTRUCTORS

=over

=item new( args )

Describe constructor

=back

=head1 METHODS

=over

=item method( args )

Describe method

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
