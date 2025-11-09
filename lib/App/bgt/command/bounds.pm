use v5.42;
use utf8;

package App::bgt::command::bounds;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	my $bounds = $class->gpx_tool($args[0])->bounds;
	$class->to_json($bounds);
	}

sub description ($class) {
	"outputs the bounding boxes for the gpx file";
	}

no feature 'module_true';
__PACKAGE__;

=encoding utf8

=head1 NAME

App::bgt::command::bounds - returns the bounding box for the GPX file

=head1 SYNOPSIS

Each key is the fraction of points in that bounding box. For example, 25% of
the points are in the C<0.25> bounding box:

	% bgt bounds path.gpx | jq -r .
	{
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
