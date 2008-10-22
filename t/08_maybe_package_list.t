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

use Test::More tests => 24;

local $SIG{__WARN__} = sub { BAIL_OUT( $_[0] ) };

no warnings 'once';


eval q{
    use maybe 'maybe::Test1' => 'string';
};
is( $@, '',                                              'use maybe "maybe::Test1" succeed' );
is( $INC{'maybe/Test1.pm'}, 't/tlib/maybe/Test1.pm',     '%INC for maybe/Test1.pm is set' );
is( maybe::Test1->VERSION, 123,                          'maybe::Test1->VERSION == 123' );
is( $maybe::Test1::is_ok, 'string',                      '$maybe::Test1::is_ok eq "string"' );

eval q{
    use maybe 'maybe::Test2' => 'string';
};
is( $@, '',                                              'use maybe "maybe::Test2" succeed' );
is( $INC{'maybe/Test2.pm'}, 't/tlib/maybe/Test2.pm',     '%INC for maybe/Test2.pm is set' );
is( maybe::Test2->VERSION, undef,                        'maybe::Test2->VERSION is undef' );
is( $maybe::Test2::is_ok, 'string',                      '$maybe::Test2::is_ok eq "string"' );

eval q{
    use maybe 'maybe::Test3' => 'string';
};
is( $@, '',                                              'use maybe "maybe::Test3" succeed' );
is( $INC{'maybe/Test3.pm'}, 't/tlib/maybe/Test3.pm',     '%INC for maybe/Test3.pm is set' );
is( maybe::Test3->VERSION, 123,                          'maybe::Test3->VERSION == 123' );
is( $maybe::Test3::is_ok, 0,                             '$maybe::Test3::is_ok == 0' );

eval q{
    use maybe 'maybe::Test4' => 'string';
};
is( $@, '',                                              'use maybe "maybe::Test4" succeed' );
is( $INC{'maybe/Test4.pm'}, undef,                       '%INC for maybe/Test4.pm is undef' );
is( maybe::Test4->VERSION, 123,                          'maybe::Test4->VERSION == 123' );
is( $maybe::Test4::is_ok, 0,                             '$maybe::Test4::is_ok == 0' );

eval q{
    use maybe 'maybe::Test5' => 'string';
};
is( $@, '',                                              'use maybe "maybe::Test5" succeed' );
if ($] >= 5.010) {
    is( $INC{'maybe/Test5.pm'}, undef,                   '%INC for maybe/Test5.pm is undef' );
    is( maybe::Test5->VERSION, 123,                      'maybe::Test5->VERSION == 123' );
    is( $maybe::Test5::is_ok, 0,                         '$maybe::Test5::is_ok == 0' );
}
elsif ($] >= 5.008) {
    is( $INC{'maybe/Test5.pm'}, 't/tlib/maybe/Test5.pm', '%INC for maybe/Test5.pm is set' );
    is( maybe::Test5->VERSION, 123,                      'maybe::Test5->VERSION == 123' );
    is( $maybe::Test5::is_ok, 0,                         '$maybe::Test5::is_ok == 0' );
}
else {
    is( $INC{'maybe/Test5.pm'}, 't/tlib/maybe/Test5.pm', '%INC for maybe/Test5.pm is set' );
    is( maybe::Test5->VERSION, undef,                    'maybe::Test5->VERSION is undef' );
    is( $maybe::Test5::is_ok, undef,                     '$maybe::Test5::is_ok is undef' );
}

eval q{
    use maybe 'maybe::Test0' => 'string';
};
is( $@, '',                                              'use maybe "maybe::Test0" succeed' );
is( $INC{'maybe/Test0.pm'}, undef,                       '%INC for maybe/Test0.pm is undef' );
is( maybe::Test0->VERSION, undef,                        'maybe::Test0->VERSION is undef' );
is( $maybe::Test0::is_ok, undef,                         '$maybe::Test0::is_ok is undef' );
