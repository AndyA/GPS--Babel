package GPS::Babel::Object;

use warnings;
use strict;
use Carp;
use Time::Local;
use Scalar::Util qw(blessed);

sub append {
    my $self = shift;
    for my $a (@_) {
        if (my $ref = ref($a)) {
            if ($ref eq 'ARRAY') {
                $self->add(@{$a});
            } elsif (blessed($a) && $a->can('as_array')) {
                $self->add($a->as_array);
            } else {
                croak "can't append a $ref";
            }
        } else {
            $self->add($a);
        }
    }
}

sub as_array {
    return shift;
}

sub _from_gpx_time {
    my ($self, $tm) = @_;

    unless ($tm =~ /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/) {
        confess "Badly formatted time: $tm";
    }

    my ($yr, $mo, $da, $hr, $mi, $se) = ($1, $2, $3, $4, $5, $6);

    return timegm($se, $mi, $hr, $da, $mo-1, $yr);
}

sub _to_gpx_time {
    my ($self, $tm) = @_;

    my ($se, $mi, $hr, $da, $mo, $yr) = gmtime($tm);
    return sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ",
                        $yr + 1900, $mo + 1, $da, $hr, $mi, $se);
}

# Subclass to provide per-object conversion semantics

sub _from_gpx {
    my ($self, $name, $val) = @_;
    confess unless defined $name;
    if ($name eq 'time') {
        return $self->_from_gpx_time($val);
    } else {
        return $val;
    }
}

sub _to_gpx {
    my ($self, $name, $val) = @_;
    if ($name eq 'time') {
        return $self->_to_gpx_time($val);
    } else {
        return $val;
    }
}

# Utility function: clone an arbitrary object. Not a method
sub _clone_object {
    my $obj = shift;
    return $obj
        unless ref $obj;
    return $obj->clone()
        if blessed($obj) && $obj->can('clone');
    return $obj;
}

1; # Magic true value required at end of module
__END__

=head1 NAME

GPS::Babel::Object - Base class for GPS::Babel objects. Never instantiated directly.

=head1 VERSION

This document describes GPS::Babel::Object version 0.0.2

=head1 SYNOPSIS

    use GPS::Babel;

=head1 DESCRIPTION

This is the base class for C<GPS::Babel::Node> and C<GPS::Babel::Collection> and indirectly
via C<GPS::Babel::Node> C<GPS::Babel::Data> and C<GPS::Babel::Point> - all
the objects that comprise a C<GPS::Babel::Data> object.

=head1 CONSTRUCTORS

Never directly instantiated.

=head1 METHODS

=over

=item append( objref ... )

Append objects. All subclasses of C<GPS::Babel::Object> are capable of bahaving as
containers for other objects. Objects can be added to either by calling

    $obj->add($thing);

or

    $obj->append($thing);

The difference is that C<append> will flatten any argument that is an array reference
or a reference to an object that supports the C<as_array> method and call C<add> for
each of the objects it contains.

Use append to, for example, append a track to the end of another track.

    # Add points in $other_track to $track
    $track->append($other_track);

=item as_array

By default returns the C<GPS::Babel::Object> itself. Implemented with appropriate
semantics in subclasses.

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
