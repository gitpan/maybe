#!/usr/bin/perl

use strict;
use warnings;

use File::Spec;
use Cwd;

BEGIN {
    unshift @INC, map { /(.*)/; $1 } split(/:/, $ENV{PERL5LIB}) if defined $ENV{PERL5LIB} and ${^TAINT};

    my $cwd = ${^TAINT} ? do { local $_=getcwd; /(.*)/; $1 } : '.';
    unshift @INC, File::Spec->catdir($cwd, 'inc');
    unshift @INC, File::Spec->catdir($cwd, 'lib');
    unshift @INC, File::Spec->catdir($cwd, 't/tlib');
}

use Test::More tests => 4;

local $SIG{__WARN__} = sub { BAIL_OUT( $_[0] ) };

no warnings 'once';


eval q{
    use maybe 'maybe::Test1' => 'string', '';
};
is( $@, '',                                          'use maybe "maybe::Test1" succeed' );
is( $INC{'maybe/Test1.pm'}, 't/tlib/maybe/Test1.pm', '%INC for maybe/Test1.pm is set' );
is( maybe::Test1->VERSION, 123,                      'maybe::Test1->VERSION == 123' );
is( $maybe::Test1::is_ok, 'string',                  '$maybe::Test1::is_ok eq "string"' );
