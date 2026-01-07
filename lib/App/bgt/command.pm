use v5.42;
use utf8;

package App::bgt::command;

use File::Basename;

=encoding utf8

=head1 NAME

App::bgt::command - base module for commands

=head1 SYNOPSIS


	package App::bgt::command::foo;
	use parent qw(App::bgt::command);

	sub description ($class) { "..." }

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * app_name

Returns that application name.

=cut

sub app_name ($class) {
	basename($0);
	}

=item * description

Returns a placeholder string for the command description. Command modules
should override this.

=cut

sub description ($class) {
	"<no description>"
	}

=item * gpx_tool

Loads the module that handles GPX stuff (L<App::bgt::GpxTools>) and returns
its class name.

=cut

sub gpx_tool ($class, $file) {
	state $rc = require App::bgt::GpxTools;
	my $gpx_tool = App::bgt::GpxTools->new($file);
	}

=item * name

Returns the command name, which is really just the last part of the command
module name.

=cut

sub name ($class) {
	$class =~ s/.*:://r;
	}

=item * subdirs

Returns the relative subdirs to append to each entry in C<@INC> when looking
for additional commands.

=cut

sub subdirs ($class) {
	my @dirs = split /::/, $class;
	pop @dirs;
	@dirs;
	}

=item * to_json(REF)

Turns REF into JSON.

=cut

sub to_json ($class, $data) {
	state $rc = require Mojo::JSON;
	Mojo::JSON::encode_json($data);
	}

=item * version

Returns the application version, which is the same as the module version.

=cut

sub version ($class) {
	$App::bgt::VERSION;
	}

no feature 'module_true';
__PACKAGE__;

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

