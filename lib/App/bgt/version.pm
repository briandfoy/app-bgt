use v5.42;
use utf8;
no feature 'module_true';

package App::bgt::version;
use vars qw(@ISA);
push @ISA, qw(App::bgt::base);

sub run ($class, @args) {
	printf "%s %s\n", $class->app_name, $class->version;
	}

sub description ($class) {
	"outputs the version and exits";
	}

__PACKAGE__;
