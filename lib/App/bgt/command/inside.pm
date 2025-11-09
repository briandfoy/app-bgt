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

	my $summary = $class->gpx_tool($file)->summary;
	return unless defined $summary;

	my @fences = App::bgt::Geofence->extract_fences_from_kml(@args);

	my %shapes;
	$shapes{'meta'}{'file'} = $file;
	$shapes{'summary'}      = $summary;
	$shapes{'fences'}       = [];

	foreach my $fence ( @fences ) {
		my $this = { gpx => $file };
		$this->{'fence'}{'name'} = $fence->name;
		$this->{'fence'}{'file'} = $fence->file;
		$this->{'fence'}{'bounding_box_area'} = $fence->bounding_box_area;
		$this->{'fence'}{'bounding_box'} = $fence->bounding_box;

		$this->{'inside_percent'}  = $fence->fraction_inside($summary->{'points'});
		$this->{'outside_percent'} = 1 - $this->{'inside_percent'};

		push $shapes{'fences'}->@*, $this;
		}

	\%shapes;
	}

sub description ($class) {
	"returns data on the overlap of the trackpoints and the shape";
	}

no feature 'module_true';
__PACKAGE__;

=encoding utf8

=head1 NAME

App::bgt::command::inside - output stats of which fences contain points

=head1 SYNOPSIS

Outputs statistics about how the path fits into the fences:

	$ bgt inside corpus/gpx/*west.gpx corpus/kml/*.kml | jr -r '.fences'
	[
	  {
		"fence": {
		  "bounding_box": [
			[
			  -73.8290389778693,
			  40.6084637497242
			],
			[
			  -73.8151618927996,
			  40.635390891343
			]
		  ],
		  "file": "corpus/kml/Jamaica Bay Wildlife Refuge - East.kml",
		  "name": "Jamaica Bay Wildlife Refuge - East"
		},
		"gpx": "corpus/gpx/jamaica_bay_west.gpx",
		"inside_percent": 0,
		"outside_percent": 1
	  },
	...
	]

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * run( FILE )

=item * description

=back

=head1 SOURCE AVAILABILITY

This module is on Github:

	https://github.com/briandfoy/app-bgt

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2025, brian d foy C<< <briandfoy@pobox.com> >>. All rights reserved.
This software is available under the Artistic License 2.0.

=cut
