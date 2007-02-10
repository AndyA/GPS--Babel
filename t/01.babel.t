use strict;
use warnings;
use GPS::Babel;
use Data::Dumper;
use Test::More tests => 12;

my $DUMMY_EXE = 'not-the-real-gpsbabel';
our $exe_name = $DUMMY_EXE;

# Fake system
{

    package GSP::Babel;

    use subs qw(system which);
    no warnings qw(redefine once);

    package main;

    *GPS::Babel::system = sub {
        my @args = @_;
        diag "system: ", join( ' ', @args );
    };

    *GPS::Babel::which = sub {
        my $name = shift;
        diag "which: $name";
        return $exe_name;
    };
}

{

    # No exe specified
    local $exe_name = undef;
    {
        ok my $babel = GPS::Babel->new(), 'new OK';
        isa_ok $babel, 'GPS::Babel';
        ok !$babel->get_exename, 'no exe found OK';
        eval { $babel->check_exe };
        like $@, qr/not\s+found/, 'check_exe errors correctly';
    }

    # Dummy exe specified
    {
        ok my $babel = GPS::Babel->new( { exename => $DUMMY_EXE } ), 'new OK';
        isa_ok $babel, 'GPS::Babel';
        is $babel->get_exename, $DUMMY_EXE, 'exe as arg OK';
        eval { $babel->check_exe };
        ok !$@, 'check_exe ok correctly';
    }
}

{
    ok my $babel = GPS::Babel->new(), 'new OK';
    isa_ok $babel, 'GPS::Babel';
    is $babel->get_exename, $DUMMY_EXE, 'exe found OK';
    eval { $babel->check_exe };
    ok !$@, 'check_exe ok correctly';
    
    my $got = $babel->get_info;
    my $want = { };
    is_deeply $got, $want, 'get_info parses OK';
}

#
#
# my $babel   = GPS::Babel->new();
# my $exename = $babel->get_exename();
#
# unless (defined $exename) {
#     plan skip_all => "Can't find gpsbabel binary";
#     exit;
# }
#
# plan tests => 1;
#
# ok(1, 'All done');
