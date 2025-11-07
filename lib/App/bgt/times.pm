use v5.42;
use utf8;
no feature 'module_true';

package App::bgt::times;
use vars qw(@ISA);
push @ISA, qw(App::bgt::base);

sub run ($class, @args) {
	my $times = App::bgt::GpxTools->times($args[0]);
	exit(1) unless defined $times;
	say $class->to_json($times);
	exit(0);
	}

sub description ($class) {
	"outputs the earliest and latest times for the gpx file";
	}

__PACKAGE__;
