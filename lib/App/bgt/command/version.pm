use v5.42;
use utf8;

package App::bgt::command::version;
use parent qw(App::bgt::command);

sub run ($class, @args) {
	sprintf "%s %s", $class->app_name, $class->version;
	}

sub description ($class) {
	"outputs the version and exits";
	}

no feature 'module_true';
__PACKAGE__;

=encoding utf8

=head1 NAME

App::bgt::command::version - output a version message

=head1 SYNOPSIS

Prints the help message is there are no arguments, or just C<help>:

	% bgt version
	bgt 0.001_01

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
