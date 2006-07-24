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
    no strict 'refs';
    for my $singular (qw(route track waypoint)) {
        my $plural = $singular . 's';
        my $accessor = sub {
            my $self = shift;
            return $self->collection_accessor(\$self->{$plural}, @_);
        };
        # Generate singular version
        *{"GPS::Babel::Data::$singular"} = $accessor;
        # Generate plural version
        *{"GPS::Babel::Data::$plural"} = $accessor;
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
    
    # print "Unhandled keys:\n";
    # for (sort keys %unk) {
    #     print "$_\n";
    # }
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

# Sanity check the structure of the tree - croak if it's bad
sub check_structure {
    
}

# Return an iterator that will visit all points

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
