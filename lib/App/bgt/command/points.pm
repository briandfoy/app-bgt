use v5.42;
use utf8;

package App::bgt::command::points;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	my $summary = $class->gpx_tool($args[0])->summary;
	return unless defined $summary;
	$class->to_json($summary->{'points'});
	}

sub description ($class) {
	"outputs the track points as JSON";
	}

no feature 'module_true';
__PACKAGE__;

=encoding utf8

=head1 NAME

App::bgt::command::points - output the points in the path

=head1 SYNOPSIS

Outputs the points as JSON array:

	$ bgt points corpus/gpx/*west.gpx corpus/kml/*.kml | jr -r .
	[
	  {
		"ele": 0,
		"lat": 40.6168566975714,
		"lon": -73.8346959419079,
		"name": 88,
		"time": 1483194511
	  },
	  {
		"ele": 0,
		"lat": 40.6166930382612,
		"lon": -73.8346864111487,
		"name": 89,
		"time": 1483194591
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

Copyright © 2025-2026, brian d foy C<< <briandfoy@pobox.com> >>. All rights reserved.

This software is available under the Artistic License 2.0.

=cut
