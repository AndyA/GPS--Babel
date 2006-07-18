package GPS::Babel::Object;

use warnings;
use strict;
use Carp;
use Time::Local;

our $AUTOLOAD;

sub new {
    my $proto   = shift;
	my $class   = ref($proto) || $proto;

    #print "GPS::Babel::Object->new()\n";

	my $self = {
	    attr        => { },
	    children    => [ ]
    };
    
	return bless $self, $class;
}

# Automatically provide accessor methods named after
# fields.
# sub AUTOLOAD {
# 	my $self = shift;
# 	my $type = ref($self)
# 		    or croak "$self is not an object";
# 
# 	my $name = $AUTOLOAD;
# 
# 	$name =~ s/.*://;   # strip fully-qualified portion
# 
# 	if (@_) {
# 	    return $self->{attr}->{$name} = shift;
# 	} else {
# 	    return $self->{attr}->{$name};
# 	}
# }

sub add_child {
    my ($self, $path, $name, $obj) = @_;
    #print "add_child($self, \"$path\", \"$name\", $obj)\n";
    push @{$self->{children}}, $obj;
}

sub set_attr {
    my ($self, $path, $name, $value) = @_;
    #print "set_attr($self, \"$path\", \"$name\", \"$value\")\n";
    $self->{attr}->{$name} = $value;
}

sub tidy_text {
    my ($self, $str) = @_;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $str =~ s/\s+/ /g;
    return $str;
}

sub from_gpx_time {
    my ($self, $tm) = @_;
    
    unless ($tm =~ /^(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z$/) {
        die "Badly formatted time: $tm\n";
    }

    my ($yr, $mo, $da, $hr, $mi, $se) = ($1, $2, $3, $4, $5, $6);

    return timegm($se, $mi, $hr, $da, $mo-1, $yr);
}

sub to_gpx_time {
    my ($self, $tm) = @_;
    
    my ($se, $mi, $hr, $da, $mo, $yr) = gmtime($tm);
    return sprintf("%04d-%02d-%02dT%02d:%02d:%02dZ",
                        $yr, $mo + 1, $da, $hr, $mi, $se);
}

# Subclass to provide per-object conversion semantics

sub from_gpx {
    my ($self, $path, $name, $val) = @_;
    #print "$path, $name, $val\n";
    die unless defined $name;
    if ($name eq 'time') {
        return $self->from_gpx_time($val);
    } else {
        return $val;
    }
}

sub to_gpx {
    my ($self, $path, $name, $val) = @_;
    if ($name eq 'time') {
        return $self->to_gpx_time($val);
    } else {
        return $val;
    }
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
