use v5.42;
use utf8;

package App::bgt::command;

sub app_name ($class) {
	'bgt'
	}

sub description ($class) {
	"<no description>"
	}

sub gpx_tool ($class) {
	state $rc = require App::bgt::GpxTools;
	return 'App::bgt::GpxTools';
	}

sub name ($class) {
	$class =~ s/.*:://r;
	}

sub subdirs ($class) {
	my @dirs = split /::/, $class;
	pop @dirs;
	@dirs;
	}

sub to_json ($class, $data) {
	state $rc = require Mojo::JSON;
	Mojo::JSON::encode_json($data);
	}

sub version ($class) {
	$App::bgt::VERSION;
	}

no feature 'module_true';
__PACKAGE__;
