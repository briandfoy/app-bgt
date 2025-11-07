use v5.42;
use utf8;
no feature 'module_true';

package App::bgt::summary;
use vars qw(@ISA);
push @ISA, qw(App::bgt::base);

sub run ($class, @args) {
	my $summary = App::bgt::GpxTools->summary($args[0]);
	exit(1) unless defined $summary;
	say Data::Dumper::Dumper($summary);
	exit(0);
	}

sub description ($class) {
	"outputs a summary of the data collected";
	}

__PACKAGE__;
