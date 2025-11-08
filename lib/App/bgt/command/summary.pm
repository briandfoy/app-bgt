use v5.42;
use utf8;

package App::bgt::command::summary;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	my $summary = $class->gpx_tool->summary($args[0]);
	return unless defined $summary;
	delete $summary->{'points'};
	$summary;
	}

sub description ($class) {
	"outputs a summary of the data collected";
	}

no feature 'module_true';
__PACKAGE__;
