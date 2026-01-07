use v5.42;
use utf8;

package App::bgt::command::help;
use parent qw(App::bgt::command);

use File::Basename qw(basename);
use File::Spec::Functions qw(catfile);

sub run ($class, @args) {
	my %commands;
	my $longest = 0;

	$commands{$class->name} = $class->description;

	foreach my $dir ( @INC ) {
		my $subdir = catfile( $dir, $class->subdirs );
		next unless -d $subdir;

		my $glob = catfile( $subdir, '*.pm' );

		foreach my $pm_file ( glob($glob) ) {
			next if basename($pm_file) =~ s/\.pm\z//r eq $class->name;
			my $package = eval qq(require "./$pm_file");
			next unless defined $package;

			my $name        = $package->name;
			my $description = $package->description;

			$commands{$name} = $description;

			$longest = length $name if length $name > $longest;
			}
		}

	my $string = $class->app_name . "\n";
	foreach my $name ( sort keys %commands ) {
		$string .= sprintf "    %-${longest}s  -  %s\n", $name, $commands{$name};
		}

	$string;
	}

sub description ($class) {
	"outputs the help message and exits";
	}

no feature 'module_true';
__PACKAGE__;

=encoding utf8

=head1 NAME

App::bgt::command::help - list all of the commands

=head1 SYNOPSIS

Prints the help message is there are no arguments, or just C<help>:

	% bgt

	% bgt help
	bgt
		bounds   -  outputs the bounding boxes for the gpx file
		help     -  outputs the help message and exits
		inside   -  returns data on the overlap of the trackpoints and the shape
		points   -  outputs the track points as JSON
		summary  -  outputs a summary of the data collected
		times    -  outputs the earliest and latest times for the gpx file
		version  -  outputs the version and exits

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
