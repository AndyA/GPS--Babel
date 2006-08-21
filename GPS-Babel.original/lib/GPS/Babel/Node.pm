package GPS::Babel::Node;

use warnings;
use strict;
use Carp;
use GPS::Babel::Collection;
use GPS::Babel::Iterator;
use GPS::Babel::Object;
use GPS::Babel::Util;
use HTML::Entities;
use Scalar::Util qw(blessed);

our $AUTOLOAD;

our @ISA = qw(GPS::Babel::Object);

sub new {
    my $proto   = shift;
	my $class   = ref($proto) || $proto;

    if (@_ && (my $ref = ref $_[0])) {
        if ($ref eq 'HASH') {
            @_ = ( %{$_[0]} );
        } elsif (blessed($_[0]) && $_[0]->can('clone')) {
            return $_[0]->clone;
        } else {
            croak "Can't create an object with a $ref";
        }
    }

    my $self = {
        attr => { @_ },
    };

	return bless $self, $class;
}

# Return a deep copy of the current object
sub clone {
    my $self = shift;
    my $new  = { attr => { } };
    $new->{item} = $self->{item}->clone()
        if $self->{item};
    while (my ($n, $v) = each(%{$self->{attr}})) {
        $new->{attr}->{$n} = GPS::Babel::Object::_clone_object($v);
    }
    return bless $new, ref($self);
}

# Automatically provide accessor methods named after
# fields.
sub AUTOLOAD {
	my $self = shift;
	my $type = ref($self)
		    or croak "$self is not an object";

	my $name = $AUTOLOAD;

	$name =~ s/.*://;   # strip fully-qualified portion

    return $self->attr($name, @_);
}

sub attr {
    my $self = shift;
    my $name = shift;
	if (@_) {
	    return $self->{attr}->{$name} = shift;
	} else {
	    return $self->{attr}->{$name};
	}
}

sub attr_names {
    my $self = shift;
    return keys %{$self->{attr}};
}

sub _collection_accessor {
    my $self = shift;
    my $ref  = shift;
    if (@_) {
        my $obj = shift;
        # TODO: Add any object that supports as_array() ?
        if (ref($obj) eq 'ARRAY') {
            # Turn an array into a collection
            my $col = GPS::Babel::Collection->new();
            $col->add($obj);
            $obj = $col;
        }
        confess "Must be a collection"
            unless blessed($obj) && $obj->isa('GPS::Babel::Collection');
        return $$ref = $obj;
    } else {
        return $$ref ||= GPS::Babel::Collection->new();
    }
}

sub item {
    my $self = shift;
    return $self->_collection_accessor(\$self->{item}, @_);
}

sub items {
    return item(@_);
}

sub add_child {
    my ($self, $path, $name, $obj) = @_;
    $self->add($obj);
}

# Default: place added objects in our 'item' container
sub add {
    my $self = shift;
    $self->item->add(@_);
}

sub count {
    my $self = shift;
    return $self->item->count();
}

sub empty {
    my $self = shift;
    $self->item->empty();
}

sub _set_attr {
    my ($self, $path, $name, $value) = @_;
    #print "_set_attr($self, \"$path\", \"$name\", \"$value\")\n";
    $self->attr($name, $value);
}

sub tidy_text {
    my ($self, $str) = @_;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $str =~ s/\s+/ /g;
    return $str;
}

sub all_points {
    my $self = shift;
    return $self->item->all_points();
}

sub all_nodes {
    my $self = shift;
    my @q = ( $self );
    my $it = sub {
        my $obj = shift @q || return undef;
        while (my($n, $v) = each(%{$obj})) {
            if (blessed($v) && $v->isa('GPS::Babel::Object')) {
                push @q, $v->as_array;
            }
        }
        return $obj;
    };
    return GPS::Babel::Iterator->new($it);
}

sub _open_tag {
    my ($self, $elem, $attr) = @_;
    my $tag = '<' . $elem;
    if (defined $attr) {
        while (my($n, $v) = each(%{$attr})) {
            $tag .= ' ' . $n . '="' . encode_entities($self->_to_gpx($n, $v)) . '"';
        }
    }
    return $tag . '>';
}

sub _close_tag {
    my ($self, $elem) = @_;
    return "</$elem>";
}

sub _encode_as_attr {
    my $self = shift;
    return qw(lat lon minlat minlon maxlat maxlon);
}

sub _write_contents_as_gpx {
    my ($self, $fh, $indent, $path) = @_;
    $self->item->_write_as_gpx($fh, $indent, $path);
}

sub _write_str {
    my $self = shift;
    my $fh   = shift;
    $fh->print(@_) or croak "Write error ($!)";
}

sub _write_as_gpx {
    my ($self, $fh, $indent, $path, @exc) = @_;
    my $elem;
    my $spc = '    ';
    my $pad = $spc x $indent;
    if ($path =~ m!^(.+?)/(.+)$!) {
        ($elem, $path) = ($1, $2);
    } else {
        ($elem, $path) = ($path, undef);
    }
    my %attr = ( );
    my %item = ( );
    my @as_attr = $self->_encode_as_attr();
    my %is_attr = ( );
    @is_attr{@as_attr} = @as_attr;
    my %exc = ( );
    @exc{@exc} = @exc;
    while (my($n, $v) = each(%{$self->{attr}})) {
        next if $exc{$n};
        if ($is_attr{$n}) {
            $attr{$n} = $v;
        } else {
            $item{$n} = $v;
        }
    }
    $fh->print($pad, $self->_open_tag($elem, \%attr), "\n");
    while (my($n, $v) = each(%item)) {
        $self->_write_str($fh, $pad, $spc, $self->_open_tag($n));
        $self->_write_str($fh, encode_entities($self->_to_gpx($n, $v)));
        $self->_write_str($fh, $self->_close_tag($n), "\n");
    }
    $self->_write_contents_as_gpx($fh, $indent + 1, $path);
    $self->_write_str($fh, $pad, $self->_close_tag($elem), "\n");
}

1; # Magic true value required at end of module
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
