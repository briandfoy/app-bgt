use v5.42;
use utf8;

package App::bgt::command::bounds;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	my $bounds = $class->gpx_tool->bounds($args[0]);
	return unless defined $bounds;
	$class->to_json($bounds);
	}

sub description ($class) {
	"outputs the bounding boxes for the gpx file";
	}

no feature 'module_true';
__PACKAGE__;
