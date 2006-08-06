package GPS::Babel;

=head1 NAME

GPS::Babel - Easy manipulation of GPS waypoints, tracks & routes

=head1 VERSION

This document describes GPS::Babel version 0.0.2

=head1 SYNOPSIS

    use GPS::Babel;

    my $babel = GPS::Babel->new();

    # Read a gpx file. All formats supported by gpsbabel are supported
    my $data = $babel->read('name' => 'raw.gpx', 'fmt' => 'gpx');

    # Iterate over all points
    my $iter = $data->all_points;
    # Delete points at high altitude.
    while (my $pt = $iter->()) {
        my $ele = $pt->ele;
        if (defined $ele && $ele > 300) {
            $iter->delete_current();
        }
    }

    # Rename first route
    if ($data->routes->count > 0) {
        $data->route->[0]->name('First Route');
    }

    # Write as a KML file
    $babel->write($data, 'name' => 'out.kml', 'fmt' => 'kml');

    # Make new GPS data
    my $data2 = GPS::Babel::Data->new();

    # Copy waypoints from original data
    $data2->waypoints->append($data->waypoints->clone);

    # Write as GPX file
    $babel->write($data2, 'name' => 'waypoints.gpx', 'fmt' => 'gpx');

=head1 DESCRIPTION

gpsbabel (L<http://gpsbabel.org/>) can translate between more than 90
different file formats used for GPS data and supports upload and
download to Garmin, Magellan and other GPS devices.

GPS::Babel uses gpsbabel as an input and output filter and provides a
simple object oriented interface to GPS data.

=cut

use warnings;
use strict;
use Carp;

use version; our $VERSION = qv('0.0.2');

use File::Which qw(which);
use IO::Pipe;
use GPS::Babel::Data;

my $EXENAME = 'gpsbabel';

=head1 CONSTRUCTORS

=over

=item new( exe => exename )

Constructs a new object optionally supplying the pathname of the
instance of gpsbabel that should be used. If the exe option is omitted
the value of File::Which::which('gpsbabel') will be used.

=cut

sub new {
    my $proto   = shift;
    my %opts    = @_;
	my $class   = ref($proto) || $proto;

	my $self = {
	    exe => $opts{exe} || which($EXENAME) || undef
    };

    croak "Can't find gpsbabel"
        unless defined $self->{exe};

	return bless $self, $class;
}

=back

=head1 METHODS

=over

=item read( name => filename, fmt => input_format )

Read data from a file. Returns a L<GPS::Babel::Data|GPS::Babel::Data>
object. The C<fmt> option may be any data format supported by gpsbabel.

=cut

# TODO: If source is a file handle pipe the contents into gpsbabel

sub read {
    my $self = shift;
    my %opts = @_;
    my $fmt  = $opts{fmt}  || croak "Must supply the format to read";
    my $name = $opts{name} || croak "Must supply the name of a file to read";
    my @args = ($self->{exe}, '-p', '',
                qw(-r -w -t -i),
                $opts{fmt}, '-f', $name,
                qw(-o gpx -F -));
    #print join(' ', @args), "\n";
    my $fh = IO::Pipe->new();
    $fh->reader(@args);
    croak "gpsbabel failed ($!)"
        if $fh->eof;
    my $data = GPS::Babel::Data->new();
    $data->read_from_gpx($fh);
    $fh->close();
    croak "gpsbabel failed (" . ($?>>8) . ")" if $?;
    return $data;
}

# TODO: If destination is a file handle pipe the output of gpsbabel to it

=item write( L<GPS::Babel::Data|GPS::Babel::Data>, name => filename, fmt => output_format )

Write data to a file. Any format supported by gpsbabel may be used.

=cut

sub write {
    my $self = shift;
    my $data = shift;
    my %opts = @_;
    my $fmt  = $opts{fmt}  || croak "Must supply the format to write";
    my $name = $opts{name} || croak "Must supply the name of a file to write";
    my @args = ($self->{exe}, '-p', '',
                qw(-r -w -t -i gpx -f - -o),
                $fmt, '-F', $name);
    #print join(' ', @args), "\n";
    my $fh = IO::Pipe->new();
    $fh->writer(@args);
    $data->write_as_gpx($fh);
    $fh->close() or croak "Write error ($!)";
    croak "gpsbabel failed (" . ($?>>8) . ")" if $?;
}

# TODO: Add interface that allows data to be piped through gpsbabel filters
# my $newdata = $babel->filter($data, blah)

1; # Magic true value required at end of module
__END__

=back

=head1 DIAGNOSTICS

=over

=item C<< Must supply the format to read/write >>

The C<fmt> option must be supplied to read/write().

=item C<< Must supply the name of a file to read/write >>

A filename must be supplied to read/write() in the C<name> option.

=item C<< gpsbabel failed (%s) >>

The gpsbabel binary couldn't be executed or failed with an error.

=back

=head1 CONFIGURATION AND ENVIRONMENT

GPS::Babel requires no configuration files or environment variables.

Note that options set in gpsbabel.ini will not be processed.

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
