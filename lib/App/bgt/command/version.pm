use v5.42;
use utf8;

package App::bgt::comand::version;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	sprintf "%s %s\n", $class->app_name, $class->version;
	}

sub description ($class) {
	"outputs the version and exits";
	}

no feature 'module_true';
__PACKAGE__;
