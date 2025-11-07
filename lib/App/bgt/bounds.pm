use v5.42;
use utf8;
no feature 'module_true';

package App::bgt::bounds;
use vars qw(@ISA);
push @ISA, qw(App::bgt::base);

sub run ($class, @args) {
	my $bounds = App::bgt::GpxTools->bounds($args[0]);
	exit(1) unless defined $bounds;
	say Data::Dumper::Dumper($bounds);
	exit(0);
	}

sub description ($class) {
	"outputs the bounding box for the gpx file";
	}

__PACKAGE__;
