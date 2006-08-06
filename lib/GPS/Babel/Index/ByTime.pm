package GPS::Babel::Index::ByTime;

use warnings;
use strict;
use Carp;
use Scalar::Util qw(blessed);

use GPS::Babel::Point;

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
        points  => \@pts
    };

    return bless $self, $class;
}

# Returns the index of the first point who's time is >= the supplied time
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

sub _lookup {
    my $self = shift;
    my $time = shift;

    my $pos = $self->_search($time);
    if (defined $pos) {
        my $pts = $self->{points};
        my $ptm = $pts->[$pos]->[1];

        if ($ptm == $time) {
            # Exact match - just return the point
            return ( $pts->[$pos]->[0], 0, 0 );
        }

        # If we're at the first point we can't
        # interpolate with anything.
        return if $pos == 0;

        my ($p1, $p2) = ( $pts->[$pos-1], $pts->[$pos] );

        my $pt = GPS::Babel::Point->new(time => $time);
        # Linear interpolation between nearest points
        $pt->attr('lat', _interp($p1->[1], $time, $p2->[1], $p1->[2], $p2->[2]));
        $pt->attr('lon', _interp($p1->[1], $time, $p2->[1], $p1->[3], $p2->[3]));
        my ($e1, $e2) = ( $p1->[0]->attr('ele'), $p2->[0]->attr('ele') );
        if (defined $e1 && defined $e2) {
            $pt->attr('ele', _interp($p1->[1], $time, $p2->[1], $e1, $e2));
        }

        my $d1 = $time - $p1->[1];
        my $d2 = $p2->[1] - $time;
        my $time_diff = $d1 < $d2 ? $d1 : $d2;

        # Return a synthetic point
        return ( $pt, 1, $time_diff );
    }

    return;
}

# Return a point that represents the position at the specified time. In an
# array context returns the point, a flag that indicates whether the
# returned point is synthetic and the number of seconds to the nearest real
# point. If the time can't be matched the returned point will be undef.
sub lookup {
    my $self = shift;
    my @r = $self->_lookup(@_);
    return unless @r;
    return wantarray ? @r : $r[0];
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
