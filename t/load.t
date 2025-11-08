#!perl
use lib qw(lib);
my @classes;

push @namespaces, map { s/ lib\/ //x; s/\.pm\z//; s/ \/ /::/xgr }
	glob('lib/App/*.pm lib/App/bgt/*.pm lib/App/bgt/command/*.pm');


use Test::More;

foreach my $class ( @namespaces ) {
	BAIL_OUT( "$class did not compile: $@\n" ) unless use_ok( $class );
	}

done_testing();
