package GPS::Babel::Data;

use warnings;
use strict;
use Carp;

use XML::Parser;

use GPS::Babel::Node;
use GPS::Babel::Point;
use GPS::Babel::Collection;

our @ISA = qw(GPS::Babel::Node);

# use XML::Parser;
# use XML::Generator ':pretty';
# use File::Which qw(which);
# use IO::Handle;
# use GPS::Babel::Data;

# Module implementation here

# Make accessors for containers
BEGIN {
    for my $singular (qw(route track waypoint)) {
        my $plural = $singular . 's';
        my $accessor = sub {
            my $self = shift;
            return $self->collection_accessor(\$self->{$plural}, @_);
        };
        no strict 'refs';
        # Generate singular version
        *{"GPS::Babel::Data::$singular"} = $accessor;
        # Generate plural version
        *{"GPS::Babel::Data::$plural"} = $accessor;
        use strict 'refs';
    }
};

sub new {
    my ($proto, @args) = @_;

    my $class = ref($proto) || $proto;
    my $self = $class->SUPER::new(@args);

	return bless $self, $class;
}

sub read_from_gpx {
    my ($self, $fh) = @_;

    my $p = XML::Parser->new();
    my @path = ( );

    # Stack of objects being built. The top of stack is the
    # innermost object
    my @work = ( [1, $self] );

    # Stack of strings that accumulate the text in the innermost element
    my @text = ( );

    my %unk = ( );

    # Maps gpx path to GPS::Babel::Data class.
    my %path_map = (
        'gpx/bounds'            => 'GPS::Babel::Node',
        'gpx/rte'               => 'GPS::Babel::Node',
        'gpx/rte/rtept'         => 'GPS::Babel::Point',
        'gpx/trk'               => 'GPS::Babel::Node',
        'gpx/trk/trkseg'        => 'GPS::Babel::Node',
        'gpx/trk/trkseg/trkpt'  => 'GPS::Babel::Point',
        'gpx/wpt'               => 'GPS::Babel::Point'
    );

    my $char_handler = sub {
        my ($expat, $text) = @_;
        my $path = join('/', @path);
        if (@text) {
            $text[-1] .= $text;
        }
    };

    my $start_handler = sub {
        my ($expat, $elem, %attr) = @_;
        push @path, $elem;

        my $path = join('/', @path);
        if (my $cls = $path_map{$path}) {
            my $con = $cls . '::new';
            no strict 'refs';
            # Construct object
            my $obj = $con->($cls);
            # Not sure about this - makes it more complex for users
            # to create new objects if this is a dependency.
            #$obj->set_attr($path, '_gpx_element', $elem);
            for (keys %attr) {
                $obj->set_attr($path, $_, $attr{$_});
            }

            push @work, [ scalar(@path), $obj ];
        } else {
            # Should do something with attributes
            $unk{$path}++;
        }

        push @text, '';
    };

    my $end_handler = sub {
        my ($expat, $elem) = @_;

        my $path = join('/', @path);

        confess "Text stack empty"
            unless @text;

        my $val = pop @text;

        if ($path_map{$path}) {
            # Must have created an object
            my $obj = pop @work;
            my $top = $work[-1];
            my $kpath = join('/', @path[$top->[0] .. $#path]);
            $top->[1]->add_child($path, $kpath, $obj->[1]);
        } else {
            my $top = $work[-1];
            my $kpath = join('/', @path[$top->[0] .. $#path]);
            my $obj = $top->[1];
            $obj->set_attr($path, $kpath, $obj->from_gpx($kpath, $val));
        }

        my $celem = pop @path;
        confess "Unmatched $elem"
            unless $celem eq $elem;


    };

    $p->setHandlers(
        Char    => $char_handler,
        Start   => $start_handler,
        End     => $end_handler
    );

    $p->parse($fh);
}

sub set_attr {
    my ($self, $path, $name, $value) = @_;
    if ($name eq '') {
        # All spare text ends up here - it should just be whitespace
        if (length($self->tidy_text($value)) > 0) {
            confess "Junk around <gpx> </gpx>";
        }
    } else {
        $self->SUPER::set_attr($path, $name, $value);
    }
}

# Subclass add_child to stash our attributes into different containers

sub add_child {
    my ($self, $path, $name, $obj) = @_;
    if ($name eq 'bounds') {
        $self->{attr}->{bounds} = $obj;
    } elsif ($name eq 'wpt') {
        $self->waypoints->add($obj);
    } elsif ($name eq 'rte') {
        $self->routes->add($obj);
    } elsif ($name eq 'trk') {
        $self->tracks->add($obj);
    } else {
        print "*** Warning - unhandled object at $name\n";
        $self->SUPER::add_child($path, $name, $obj);
    }
}

# Default to adding waypoints
sub add {
    my $self = shift;
    $self->waypoints->add(@_);
}

sub all_points {
    my $self = shift;

    return GPS::Babel::Iterator->new_with_iterators(
        $self->waypoints->all_points,
        $self->routes->all_points,
        $self->tracks->all_points
    );
}

sub write_contents_as_gpx {
    my ($self, $fh, $indent, $path) = @_;
    $self->waypoints->write_as_gpx($fh, $indent, 'wpt');
    $self->routes->write_as_gpx($fh, $indent, 'rte/rtept');
    $self->tracks->write_as_gpx($fh, $indent, 'trk/trkseg/trkpt');
}

sub write_as_gpx {
    my ($self, $fh) = @_;
    $self->check_structure;
    $self->SUPER::write_as_gpx($fh, 0, 'gpx',
        qw(waypoints routes tracks bounds));
}

sub clone {
    my $self = shift;
    my $new = $self->SUPER::clone();
    for (qw(routes tracks waypoints)) {
        $new->{$_} = $self->{$_}->clone()
            if defined $self->{$_};
    }
    return $new;
}

sub check_structure {
    # TODO
}

1; # Magic true value required at end of module
__END__

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

=head1 CONSTRUCTORS

=over

=item new

Constructs a new object. Any arguments to the constructor are added to
the array.

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
