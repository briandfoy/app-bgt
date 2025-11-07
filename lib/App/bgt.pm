use v5.42;
use source::encoding 'utf8';
no feature qw(module_true);

package App::bgt;
use strict;
use feature qw(try);

use warnings;
no warnings;

our $VERSION = '0.001_01';

BEGIN {
package App::bgt::base {
	no feature 'module_true';

	sub app_name ($class) {
		'bgt'
		}

	sub description ($class) {
		"<no description>"
		}

	sub name ($class) {
		$class =~ s/.*:://r;
		}

	sub subdirs ($class) {
		my @dirs = split /::/, __PACKAGE__;
		pop @dirs;
		@dirs;
		}

	sub to_json ($class, $data) {
		state $rc = require Mojo::JSON;
		Mojo::JSON::encode_json($data);
		}

	sub version ($class) {
		$App::bgt::VERSION;
		}
	}

package App::bgt::GpxTools {
	use Data::Dumper;
	use Geo::Gpx;
	use List::Util qw(max min reduce);
	use Math::Trig;

	sub make_gpx ($class, $file) {
		my $gpx;

		my $message = do {
			if( ! -e $file ) {
				"file <$file> does not exist"
				}
			elsif( ! -r $file ) {
				"file <$file> is not readable"
				}
			elsif( ! defined eval { $gpx = Geo::Gpx->new( input => $file ) } ) {
				"file <$file> is not parseable"
				}
			else { () }
			};

		return do {
			if( defined $message ) {
				warn "$message\n";
				();
				}
			else {
				$gpx;
				}
			};
		}

	sub summary ($class, $file) {
		my $gpx = $class->make_gpx($file);
		return unless defined $gpx;

		my %summary;

		my $times = $summary{'times'} = {};
		$times->{'latest'}   = "-Inf";
		$times->{'earliest'} = "+Inf";

		my $center = $summary{'center'} = {};

		my $bounds = $summary{'bounds'} = {};

		my @points;

		my $iter = $gpx->iterate_points();
		while ( my $pt = $iter->() ) {
			if( exists $pt->{'time'} ) {
				$times->{'earliest'} = $pt->{'time'} if $times->{'earliest'} > $pt->{'time'};
				$times->{'latest'}   = $pt->{'time'} if $times->{'latest'}   < $pt->{'time'};
				}

			state $Re = 6_371_000;
			if( exists $pt->{'lon'} ) {
				push @points, { $pt->%* }; # Geo::Gpx has overloaded stringification

				my $lat_r = deg2rad($pt->{'lat'});
				my $lon_r = deg2rad($pt->{'lon'});

				$center->{'grand'}{'x'} += cos($lat_r) * cos($lon_r);
				$center->{'grand'}{'y'} += cos($lat_r) * sin($lon_r);
				$center->{'grand'}{'z'} += sin($lat_r);
				$center->{'grand'}{'count'} += 1;
				}
			}

		@points = sort { $a->{lon} <=> $b->{lon} || $a->{lat} <=> $b->{lat} } @points;

		foreach my $f ( 0.25, 0.50, 0.75, 0.90, 1 ) {
			# these are all 1-based
			my $points  = ceil($f * @points);
			my $discard = @points - $points;
			my $start   = int($discard / 2);
			my $end     = $start + $points - 1;

			my @range = map { $_-1 } $start .. $end;

			$bounds->{$f} = {
				maxlon => max( map { $_->{lon} } @points[@range] ),
				minlon => min( map { $_->{lon} } @points[@range] ),
				maxlat => max( map { $_->{lat} } @points[@range] ),
				minlat => min( map { $_->{lat} } @points[@range] ),
				total    => scalar @points,
				fraction => (@range / @points),
				};
			}

		$center->{'point'} = {};
		foreach my $k ( qw(x y z) ) {
			$center->{'point'}{$k} = $center->{'grand'}{$k} / $center->{'grand'}{'count'};
			}

		$center->{'lon'} = rad2deg( atan2( $center->{'point'}{'y'}, $center->{'point'}{'x'} ) );
		$center->{'hyp'} = sqrt( reduce { $a + $b } map { $_**2 } $center->{'point'}->@{qw(y x)} );
		$center->{'lat'} = rad2deg( atan2( $center->{'point'}{'z'}, $center->{'hyp'} ) );

		# make all of these numeric for the JSON output
		$summary{'points'} = [ map { my $p = $_; $p->{$_} += 0 for keys $p->%*; $p } @points ];

		return \%summary;
		}

	sub bounds ($class, $file) {
		my $summary = $class->summary($file);
		$summary->{'bounds'};
		}

	sub center ($class, $file) {
		my $gpx = $class->make_gpx($file);
		return unless defined $gpx;

		}

	sub times ($class, $file) {
		my $summary = $class->summary($file);
		[ $summary->{'times'}->@{qw(earliest latest)} ];
		}
	}
}

=encoding utf8

=head1 NAME

App::bgt - brian&#39;s GPX tools

=head1 SYNOPSIS

	use App::bgt;

=head1 DESCRIPTION

=over 4

=item new

=cut

sub new {

	}

=item init

=cut

sub init {

	}

=item run

=cut

sub run ($class, @args){
	my $command = shift @args;
	$command //= 'help';
	$command = 'help' if $command eq 'base';

	my $package = "App::bgt::$command";
	try {
		eval qq(require $package);
		say $@ if length $@;
		$package->run(@args);
		}
	catch ($e) {
		warn $e;
		exit(1) if $package eq 'App::bgt::help';
		(require App::bgt::help)->run;
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

Copyright © 2025, brian d foy, All Rights Reserved.

You may redistribute this under the terms of the Artistic License 2.0.

=cut

__PACKAGE__;
