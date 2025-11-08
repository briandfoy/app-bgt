#!perl
use v5.10;
use lib qw(lib);

use Test::More;

my $args = (require './Makefile.PL')->arguments;

foreach my $exe_file ( $args->{'EXE_FILES'}->@* ) {
	like `$^X -Ilib -c $exe_file 2>&1`, qr/syntax OK/, "$exe_file compiles";
	}

done_testing();
