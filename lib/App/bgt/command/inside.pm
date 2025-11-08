use v5.42;
use utf8;

package App::bgt::command::inside;
use parent qw(App::bgt::command);

use App::bgt::Geofence;

sub run ($class, @args) {
	my $file = shift @args;
	unless( -e $file ) {
		warn "file <$file> does not exist";
		return;
		}

	my $summary = $class->gpx_tool->summary($file);
	return unless defined $summary;

	my @fences = App::bgt::Geofence->extract_fences_from_kml(@args);

	my %shapes;
	$shapes{'meta'}{'file'} = $file;
	$shapes{'summary'} = $summary;

	foreach my $fence ( @fences ) {
		my $this = $shapes{'fences'}{$fence->name} = {};
		$this->{'fence'}{'name'} = $fence->name;
		$this->{'fence'}{'file'} = $fence->file;
		$this->{'fence'}{'bounding_box'} = $fence->bounding_box;

		$this->{'inside_percent'}       = undef;
		$this->{'outside_percent'}      = undef;

		$this->{'inside_percent'}  = $fence->fraction_inside($summary->{'points'});
		$this->{'outside_percent'} = 1 - $this->{'inside_percent'};
		}

	\%shapes;
	}

sub description ($class) {
	"returns data on the overlap of the trackpoints and the shape";
	}

no feature 'module_true';
__PACKAGE__;
