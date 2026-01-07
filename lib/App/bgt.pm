use v5.42;
use source::encoding 'utf8';

package App::bgt;
use strict;
use feature qw(try);

use Mojo::JSON;

our $VERSION = '0.001_01';

=encoding utf8

=head1 NAME

App::bgt - brian's GPX tools

=head1 SYNOPSIS

	use App::bgt;

	App::bgt->run( COMMAND, ARGS );

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * run( COMMAND, ARGS )

=cut

sub run ($class, @args){
	my $command = shift @args;
	$command //= 'help';

	my $package = "App::bgt::command::$command";
	try {
		eval qq(require $package);
		die $@ if length $@;
		my $result = $package->run(@args);

		my $output = do {
			if( ! defined $result ) { () }
			elsif( ref $result ) { Mojo::JSON::encode_json($result) }
			else { $result };
			};

		say $output if defined $output;
		exit( ! defined $output );
		}
	catch ($e) {
		warn $e;
		exit(1) if $package eq 'App::bgt::command::help';
		no warnings qw(redefine);
		(require App::bgt::command::help)->run;
		}
	}

=back

=head1 TO DO


=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is in Github:

	http://github.com/briandfoy/app-bgt

=head1 AUTHOR

brian d foy, C<< <briandfoy@pobox.com> >>

=head1 COPYRIGHT AND LICENSE

Copyright © 2025-2026, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

no feature qw(module_true);
__PACKAGE__;
