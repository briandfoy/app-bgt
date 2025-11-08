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

=encoding utf8

=head1 NAME

App::bgt::command::summary - output a summary of the path

=head1 SYNOPSIS

Outputs the computed values for the GPX path:

	$ bgt summary corpus/gpx/*west.gpx corpus/kml/*.kml | jr -r .
	{
	  "bounds": {
		"0.25": {
		  "fraction": 0.251256281407035,
		  "maxlat": 40.6228087804671,
		  "maxlon": -73.8286969566145,
		  "minlat": 40.6155163952567,
		  "minlon": -73.8314165201676,
		  "total": 199
		},
		"0.5": {
		  "fraction": 0.50251256281407,
		  "maxlat": 40.6228370620031,
		  "maxlon": -73.8274072041293,
		  "minlat": 40.6153964154386,
		  "minlon": -73.8327193078776,
		  "total": 199
		},
		"0.75": {
		  "fraction": 0.753768844221106,
		  "maxlat": 40.622890896967,
		  "maxlon": -73.8269260020572,
		  "minlat": 40.6153964154386,
		  "minlon": -73.8341196792123,
		  "total": 199
		},
		"0.9": {
		  "fraction": 0.904522613065327,
		  "maxlat": 40.622890896967,
		  "maxlon": -73.8265753477109,
		  "minlat": 40.6153964154386,
		  "minlon": -73.8345859921525,
		  "total": 199
		},
		"1": {
		  "fraction": 1,
		  "maxlat": 40.622890896967,
		  "maxlon": -73.825354694302,
		  "minlat": 40.6153964154386,
		  "minlon": -73.8346959419079,
		  "total": 199
		}
	  },
	  "center": {
		"grand": {
		  "count": 199,
		  "x": 42.0661266418223,
		  "y": -145.077291783035,
		  "z": 129.553156154562
		},
		"hyp": 0.75905981568412,
		"lat": 40.618616613644,
		"lon": -73.8301316920848,
		"point": {
		  "x": 0.211387571064434,
		  "y": -0.729031617000175,
		  "z": 0.651020885198806
		}
	  },
	  "times": {
		"earliest": 1483184354,
		"latest": 1483206255
	  }
	}

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
