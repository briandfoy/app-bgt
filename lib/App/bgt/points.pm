use v5.42;
use utf8;
no feature 'module_true';

package App::bgt::points;
use vars qw(@ISA);
push @ISA, qw(App::bgt::base);

sub run ($class, @args) {
	my $summary = App::bgt::GpxTools->summary($args[0]);
	exit(1) unless defined $summary;
	say $class->to_json($summary->{'points'});
	exit(0);
	}

sub description ($class) {
	"outputs the track points as JSON";
	}

__PACKAGE__;
