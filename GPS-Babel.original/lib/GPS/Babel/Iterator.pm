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

sub new_with_iterators($) {
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
