use v5.42;
use utf8;

package App::bgt::command::times;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	my $times = $class->gpx_tool($args[0])->times;
	return unless defined $times;
	$times;
	}

sub description ($class) {
	"outputs the earliest and latest times for the gpx file";
	}

no feature 'module_true';
__PACKAGE__;

=encoding utf8

=head1 NAME

App::bgt::command::times - output the earliest and latest times

=head1 SYNOPSIS

Outputs the earliest and latest times in the GPX file. This is a JSON array
and the values are Unix epoch times:

	$ bgt times path.gpx | jq -r .
	[
	  1483184354,
	  1483206255
	]

This is the same as the C<summary> command if you select the C<times> key:

	$ bgt summary path.gpx | jq -r .times
	{
	  "earliest": 1483184354,
	  "latest": 1483206255
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
