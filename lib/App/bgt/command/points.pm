use v5.42;
use utf8;

package App::bgt::command::points;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	my $summary = $class->gpx_tool->summary($args[0]);
	return unless defined $summary;
	$class->to_json($summary->{'points'});
	}

sub description ($class) {
	"outputs the track points as JSON";
	}

no feature 'module_true';
__PACKAGE__;
