package GPS::Babel::Iterator;

use warnings;
use strict;
use Carp;
use Scalar::Util qw(blessed);

# TODO: Add map / grep semantics and tidy up or remove gather.

# Iterator wrappers
BEGIN {

    my @funcs = qw(
        insert_before
        insert_after
        replace_current
        delete_current
        previous
        next
    );

    for my $func (@funcs) {
        my $code = sub {
            my $self = shift;
            return $self->_call_context($func, @_);
        };
        no strict 'refs';
        *{"GPS::Babel::Iterator::$func"} = $code;
        use strict 'refs';
    }
};

sub new {
    my ($proto, $iter) = @_;
    my $class = ref($proto) || $proto;

    croak "must supply a coderef"
        unless ref($iter) eq 'CODE';

    my $it = sub {
        if (@_) {
            my $cmd = shift;
            if ($cmd eq 'context') {
                return;
            } else {
                croak "Iterator can't $cmd";
            }
        } else {
            return $iter->();
        }
    };

    return bless $it, $class;
}

sub with_grep($&) {
    my ($self, $filt) = @_;

    croak "Must supply a coderef"
        unless ref $filt eq 'CODE';

    my $it = sub {
        if (@_) {
            $self->(@_);
        } else {
            for (;;) {
                local $_ = $self->();
                return undef unless defined $_;
                return $_ if $filt->();
            }
        }
    };
    return bless $it, ref($self);
}

sub with_map($&) {
    my ($self, $func) = @_;

    croak "Must supply a coderef"
        unless ref $func eq 'CODE';

    my $it = sub {
        if (@_) {
            $self->(@_);
        } else {
            for (;;) {
                local $_ = $self->();
                return undef unless defined $_;
                my $obj = $func->();
                return $obj if defined $obj;
            }
        }
    }
}

sub unique($) {
    my $self = shift;

    my %seen = ( );
    my $filt = sub {
        my $obj = $_;
        return 0 if $seen{$obj};
        $seen{$obj}++;
        return 1;
    };

    return $self->with_grep($filt);
}

sub new_with_iterators {
    my $proto = shift;
    my $class = ref($proto) || $proto;

    my @iters = @_;
    my $iter  = shift @iters;

    my $it = sub {
        if (@_) {
            return defined $iter ? $iter->(@_) : undef;
        } else {
            for (;;) {
                return undef unless defined $iter;
                my $obj = $iter->();
                return $obj if defined $obj;
                $iter = shift @iters;
            }

        }
    };

    return bless $it, $class;
}

sub new_for_array($$) {
    my ($proto, $ar) = @_;
    my $class = ref($proto) || $proto;

    croak "Must supply an array"
        unless ref($ar) eq 'ARRAY' ||
               (blessed($ar) && $ar->isa('GPS::Babel::Collection'));

    my $pos     = -1;
    my $iter    = undef;
    my $self    = undef;

    # Must declare $it before generating the closure so the closure
    # can refer to itself.
    my $it;
    $it = sub {
        if (@_) {
            my $cmd = shift;
            if ($cmd eq 'context') {
                my $context = defined $iter ? $iter->_context : undef;
                return $context || $it;
            } elsif ($cmd eq 'insert_before') {
                splice @{$ar}, $pos++, 0, shift;
            } elsif ($cmd eq 'insert_after') {
                splice @{$ar}, ++$pos, 0, shift;
            } elsif ($cmd eq 'replace_current') {
                $ar->[$pos] = shift;
            } elsif ($cmd eq 'delete_current') {
                splice @{$ar}, $pos--, 1;
            } elsif ($cmd eq 'next') {
                return $pos < scalar(@$ar) - 1 ? $ar->[$pos+1] : undef;
            } elsif ($cmd eq 'previous') {
                return $pos > 0 ? $ar->[$pos-1] : undef;
            } else {
                croak "Iterator can't $cmd";
            }
        } else {
            for (;;) {
                until (defined $iter) {
                    return undef
                        if ++$pos >= scalar(@{$ar});
                    my $obj = $ar->[$pos];
                    next unless defined $obj;
                    $iter = $obj->all_points()
                }
                my $obj = $iter->();
                return $obj if defined $obj;
                $iter = undef;
            }
            return undef
                if ++$pos >= scalar(@{$ar});
        }
    };

    return bless $it, $class;
}

sub new_for_object($$) {
    my ($proto, $obj) = @_;

    my $it = sub {
        my $res = $obj;
        $obj = undef;
        return $res;
    };
    # TODO: That ain't right... Should call the right
    # constructor in a subclass.
    return GPS::Babel::Iterator->new($it);
}

sub _context {
    my $self = shift;
    return $self->('context', @_);
}

sub _call_context {
    my $self = shift;
    my $context = $self->_context;
    if (defined($context)) {
        $context->(@_);
    } else {
        #warn "Can't find container for this point";
        return;
    }
}

sub as_array {
    my $self = shift;

    my @ar = ( );

    while (my $obj = $self->()) {
        push @ar, $obj;
    }

    return @ar;
}

sub gather($&) {
    my $self = shift;
    my $func = shift;

    return $self->with_map($func)->as_array();
}

1; # Magic true value required at end of module
__END__

=head1 NAME

GPS::Babel::Iterator - Iterate over the points in a GPS::Babel::Data object.

=head1 VERSION

This document describes GPS::Babel::Iterator version 0.0.2

=head1 SYNOPSIS

    use GPS::Babel;

    my $babel = GPS::Babel->new();

    # Load file
    my $data  = $babel->read(name => 'dump.bin', fmt => 'wbt-bin');

    # Get iterator for all the points
    my $iter  = $data->all_points

    # Iterate over all the points in the data
    while (my $pt = $iter->()) {
        # Use magic iterator accessor to find
        # the previous item in this track
        my $prev = $iter->previous;
        # Display point
        printf("%-7s %9.5f %9.5f %s\n",
            defined $prev ? '' : 'head',
            $pt->lat, $pt->lon, $pt->name);
    }


=head1 DESCRIPTION

Often it's useful to be able to visit all, or some subset, of the points in a
C<GPS::Babel::Data> without having to explicitly walk the data structure. All
of the objects in the GPS::Babel::Data tree implement two methods that return
iterators. C<all_points> returns an iterator that visits each of the points
in an object and C<all_nodes> visits all objects (collections and points)
below that point in the structure.

=head1 CONSTRUCTORS

=over

=item new( coderef )

Create a new iterator from the supplied code. The supplied coderef must itself
be an iterator that returns the next object or undef when it is exhausted.

    my @array = array_builder();
    my $pos   = 0;

    my $iter = GPS::Babel::Iterator->new(sub {
        return if $pos >= scalar @array;
        return $array[$pos++];
    });

The returned iterator can be called as the original function would have been.

    while (my $pt = $iter->()) {
        print_point($pt);
    }

=item new_with_iterators ( iterator ... )

Create a new C<GPS::Babel::Iterator> that returns the contents of each of the
supplied iterators in turn. For example

    my $combined_iter = GPS::Babel::Iterator->new_with_iterators($iter1, $iter2);

creates an iterator that returns all the items returned by $iter1 and then all
the items returned by $iter2.

=item new_for_array ( array_ref )

Create a new iterator that visits each of the elements in the supplied array.
In addition to iterating the elements of the array the returned iterator can
be used I<modify> the underlying array. See the method descriptions below for
more information.

=item new_for_object ( obj_ref )

Return an iterator that returns the supplied object and is then exhausted.
Used, for example, by C<GPS::Babel::Point> to return an iterator that, in
turn, returns the original point.

=back

=head1 METHODS

=over

=item as_array

Return an array containing all of the items that would have been returned
by an iterator.

=item delete_current

When iterating over an array delete the item most recently returned by the
iterator from the underlying array.

Note that in common with all the array access methods this only
works for arrays created by a call to C<new_for_array> - which
includes the iterators returned by an object's C<all_points>
method.

=item gather( coderef )

Return an array filled with the results of applying the supplied function
to each item returned by the iterator. This is a convenience function that
is equivalent to

    $iter->with_map($func)->as_array();

=item insert_after( point )

When iterating over an array insert a point immediately after the most
recently returned item. The inserted point will not be returned by the
iterator - i.e. the next item returned will be the point I<after> the
newly inserted point.

See C<delete_current> for an explanation of which iterators support
C<insert_after>

=item insert_before

When iterating over an array insert a point immediately before the most
recently returned item.

See C<delete_current> for an explanation of which iterators support
C<insert_before>

=item next

When iterating over an array return a reference to the point immediately
following the most recently returned point or undef if no such point
exists. Note that this is not always the same as the next point that will
be returned by the iterator. For example if the GPS data contains
multiple track segments C<next> will return undef at the last point
in each segment.

See C<delete_current> for an explanation of which iterators support
C<next>

=item previous

When iterating over an array return a reference to the point immediately
preceding the most recently returned point or undef if no such point
exists. Note that this is not always the same as the previous point that
was returned by the iterator. For example if the GPS data contains
multiple track segments C<next> will return undef at the first point
in each segment.

See C<delete_current> for an explanation of which iterators support
C<previous>

=item replace_current( point )

When iterating over an array replace the current point with the
supplied point. The new point will not be returned by the
iterator.

See C<delete_current> for an explanation of which iterators support
C<replace_current>

=item unique

Modify an iterator so that it returns each object only once. This is
useful to filter the output of an iterator that merges the output
from a number of other iterators.

    my $iter = $merged_iter->unique;

=item with_grep( coderef )

Filter an iterator so that it returns only those objects for which
the supplied coderef returns true. For example to iterate only
unnamed points

    my $iter = $data->all_points->with_grep(sub {
        ! defined $_->name
    });

=item with_map( coderef )

Modify an iterator so that it filters all returned objects through
the supplied coderef.

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
