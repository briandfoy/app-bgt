use v5.42;
use utf8;

package App::bgt::command::times;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	my $times = $class->gpx_tool->times($args[0]);
	return unless defined $times;
	$times;
	}

sub description ($class) {
	"outputs the earliest and latest times for the gpx file";
	}

no feature 'module_true';
__PACKAGE__;
