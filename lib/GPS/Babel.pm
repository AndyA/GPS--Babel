package GPS::Babel;

use warnings;
use strict;
use Carp;
use Geo::Gpx;
use File::Which qw(which);
use IO::Handle;
use Class::Std;
use Data::Dumper;

use version; our $VERSION = qv('0.0.1');

my $EXENAME = 'gpsbabel';

my %exepath :ATTR( :set<exename>, :get<exename> );
my %info    :ATTR;

sub BUILD {
    my ($self, $id, $args) = @_;

    $exepath{$id} = $args->{exename} || which($EXENAME);
    $info{$id}    = undef;
}

sub check_exe {
    my $self = shift;
    my $id   = ident($self);

    croak "$EXENAME not found"
        unless defined($exepath{$id});
}

sub _with_babel {
    my $self = shift;
    my $id   = ident($self);
    my ($mode, $opts, $cb) = @_;

    $self->check_exe();
    open(my $fh, $mode, $exepath{$id}, @{$opts}) or die "Can't execute $exepath{$id} ($!)\n";
    $cb->($fh);
    $fh->close() or die "$exepath{$id} failed ($?)\n";
}

sub _with_babel_reader {
    my $self = shift;
    my ($opts, $cb) = @_;
    
    $self->_with_babel('-|', $opts, $cb);
}

sub _tidy {
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    $str =~ s/\s+/ /g;
    return $str;
}

sub _find_info {
    my $self = shift;
    my $id   = ident($self);
    
    my $info = {
        formats => { },
        filters => { },
        for_ext => { }
    };

    # Read the version
    $self->_with_babel_reader(['-V'], sub {
        my $fh = shift;
        local $/; 
        $info->{banner} = _tidy(<$fh>);
    });

    if ($info->{banner} =~ /([\d.]+)/) {
        $info->{version} = $1;
    }
    
    # -^3 and -%1 are 1.2.8 and later
    if (_cmp_ver($info->{version}, '1.2.8') >= 0) {
        # File formats
        $self->_with_babel_reader(['-^3'], sub {
            my $fh = shift;
            while (my $ln = <$fh>) {
                chomp($ln);
                my ($type, @f) = split(/\t/, $ln);
                if ($type eq 'file') {
                    my ($modes, $name, $ext, $desc, $parent) = @f;
                    $info->{formats}->{$name} = {
                        modes   => $modes,
                        desc    => $desc,
                        parent  => $parent
                    };
                    if ($ext) {
                        $ext =~ s/^[.]//;   # At least one format has a stray '.'
                        $ext = lc($ext);
                        $info->{formats}->{$name}->{ext} = $ext;
                        push @{$info->{for_ext}->{$ext}}, $name;
                    }
                } elsif ($type eq 'option') {
                    my ($fname, $name, $desc, $type, $default, $min, $max) = @f;
                    $info->{formats}->{$fname}->{options}->{$name} = {
                        desc    => $desc,
                        type    => $type,
                        default => $default || '',
                        min     => $min     || '',
                        max     => $max     || ''
                    };
                } else {
                    # Something we don't know about - so ignore it
                }
            }
        });
    
        # Filters
        $self->_with_babel_reader(['-%1'], sub {
            my $fh = shift;
            while (my $ln = <$fh>) {
                chomp($ln);
                my ($name, @f) = split(/\t/, $ln);
                if ($name eq 'option') {
                    my ($fname, $oname, $desc, $type, @valid) = @f;
                    $info->{filters}->{$fname}->{options}->{$oname} = {
                        desc    => $desc,
                        type    => $type,
                        # Not exactly sure what this is
                        valid   => [ @valid ]
                    };
                } else {
                    $info->{filters}->{$name} = {
                        desc    => $f[0]
                    };
                }
            }
        });
    }
    
    return $info;
}

sub get_info {
    my $self = shift;
    my $id   = ident($self);
    
    return $info{$id} ||= $self->_find_info();
}

sub banner {
    my $self = shift;
    return $self->get_info()->{banner};
}

sub version {
    my $self = shift;
    return $self->get_info()->{version};
}

sub _cmp_ver {
    my ($v1, $v2) = @_;
    my @v1 = split(/[.]/, $v1);
    my @v2 = split(/[.]/, $v2);
    
    while (@v1 && @v2) {
        my $cmp = (shift @v1 <=> shift @v2);
        return $cmp if $cmp;
    }
    
    return @v1 <=> @v2;
}

sub got_ver {
    my $self = shift;
    my $need = shift;
    my $got  = $self->version();
    return _cmp_ver($got, $need) >= 0;
}

sub guess_format {
    my $self = shift;
    my $id   = ident($self);
    my $name = shift;
    my $dfmt = shift;

    croak("Missing filename")
        unless defined($name);

    my $info = $self->get_info();

    # Format specified
    if (defined($dfmt)) {
        croak("Unknown format \"$dfmt\"")
            if exists($info->{formats}) && 
               !exists($info->{formats}->{$dfmt});
        return $dfmt;
    }

    croak("Filename \"$name\" has no extension")
        unless $name =~ /[.]([^.]+)$/;
        
    my $ext  = lc($1);
    my $fmt  = $info->{for_ext}->{$ext};
    
    croak("No format handles extension .$ext")
        unless defined($fmt);

    my @fmt  = sort @{$fmt};

    return $fmt[0] if @fmt == 1;

    my $last = pop @fmt;
    my $list = join(' and ', join(', ', @fmt), $last);

    croak("Multiple formats ($list) handle extension .$ext");
}

sub convert {
    my $self   = shift;
    my $id     = ident($self);
    my $inf    = shift;
    my $outf   = shift;
    my $opts   = shift || { };
    
    my $infmt  = $self->guess_format($inf,  $opts->{in_format});
    my $outfmt = $self->guess_format($outf, $opts->{out_format});
    
    my @proc = ( );
    push @proc, '-w' if $opts->{waypoints} || $opts->{all};
    push @proc, '-t' if $opts->{tracks}    || $opts->{all};
    push @proc, '-r' if $opts->{routes}    || $opts->{all};
    
    my @opts = (
        '-p', '',
        @proc,
        '-i', $infmt,  '-f', $inf,
        '-o', $outfmt, '-F', $outf
    );
    
    $self->direct(@opts);
}

sub direct {
    my $self   = shift;
    my $id     = ident($self);
    
    $self->check_exe();
    warn(join(' ', $exepath{$id}, @_) . "\n");
    if (system($exepath{$id}, @_)) {
        croak("$EXENAME failed with error " . (($? == -1) ? $! : $?));
    }
}

# sub read {
#     my $self = shift;
#     my %opts = @_;
#     my $fmt  = $opts{fmt}  || croak "Must supply the format to read";
#     my $name = $opts{name} || croak "Must supply the name of a file to read";
#     my @args = ($self->{exe}, '-p', '',
#                 qw(-r -w -t -i),
#                 $opts{fmt}, '-f', $name,
#                 qw(-o gpx -F -));
#     #print join(' ', @args), "\n";
#     my $fh = IO::Pipe->new();
#     $fh->reader(@args);
#     croak "gpsbabel failed ($!)"
#         if $fh->eof;
#     my $data = GPS::Babel::Data->new();
#     $data->_read_from_gpx($fh);
#     $fh->close();
#     croak "gpsbabel failed (" . ($?>>8) . ")" if $?;
#     return $data;
# }
# 
# 
# sub write {
#     my $self = shift;
#     my $data = shift;
#     my %opts = @_;
#     my $fmt  = $opts{fmt}  || croak "Must supply the format to write";
#     my $name = $opts{name} || croak "Must supply the name of a file to write";
#     my @args = ($self->{exe}, '-p', '',
#                 qw(-r -w -t -i gpx -f - -o),
#                 $fmt, '-F', $name);
#     #print join(' ', @args), "\n";
#     my $fh = IO::Pipe->new();
#     $fh->writer(@args);
#     $data->_write_as_gpx($fh);
#     $fh->close() or croak "Write error ($!)";
#     croak "gpsbabel failed (" . ($?>>8) . ")" if $?;
# }


1;
__END__

=head1 NAME

GPS::Babel - Perl interface to gpsbabel

=head1 VERSION

This document describes GPS::Babel version 0.0.1

=head1 SYNOPSIS

    use GPS::Babel;

    my $babel = GPS::Babel->new();
    my $data  = $babel->read('route.ozi', 'ozi');

=for author to fill in:
    Brief code example(s) here showing commonest usage(s).
    This section will be as far as many users bother reading
    so make it as educational and exeplary as possible.
  
=head1 DESCRIPTION

=for author to fill in:
    Write a full description of the module and its features here.
    Use subsections (=head2, =head3) as appropriate.

=head1 INTERFACE 

=over

=item C<new( { options } )>

=item C<check_exe()>

=item C<get_info()>

=item C<banner()>

=item C<version()>

=item C<got_ver( $ver )>

=item C<guess_format( $filename )>

=item C<get_exename()>

=item C<set_exename( $path )>

=item C<read( $filename [, $format [, { $options } ] ] )>

=item C<write( $filename [, $format [, { $options } ] ] )>

=item C<convert( $infile, $outfile, [, { $options } ] )>

=item C<direct( @options )>

=back

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
