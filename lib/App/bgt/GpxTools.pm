use v5.42;
use utf8;

package App::bgt::GpxTools;

use Data::Dumper;
use Geo::Gpx;
use List::Util qw(max min reduce);
use Math::Trig;

=encoding utf8

=head1 NAME

App::bgt::GpxTools - manipulate GPX files for bgt

=head1 SYNOPSIS

In a command, call C<gpx_tools> to get a C<App::bgt::GpxTools> object,
then call the method your need.

	sub run ($class, @args) {
		my $stuff = $class->gpx_tool($args[0])->METHOD;

		}

=head1 DESCRIPTION

=head2 Methods

=over 4

=item * bounds(FILE)

=cut

sub bounds ($class, $file) {
	my $summary = $class->summary($file);
	$summary->{'bounds'};
	}

=item * center(FILE)

=cut

sub center ($class, $file) {
	my $gpx = $class->make_gpx($file);
	return unless defined $gpx;

	}

=item * make_gpx(FILE)

=cut

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
			"file <$file> is not parseable: $@"
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

=item * summary(FILE)

=cut

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
			maxlon => 0 + max( map { $_->{lon} } @points[@range] ),
			minlon => 0 + min( map { $_->{lon} } @points[@range] ),
			maxlat => 0 + max( map { $_->{lat} } @points[@range] ),
			minlat => 0 + min( map { $_->{lat} } @points[@range] ),
			total    => 0 + scalar @points,
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

=item * times(FILE)

=cut

sub times ($class, $file) {
	my $summary = $class->summary($file);
	[ $summary->{'times'}->@{qw(earliest latest)} ];
	}

no feature qw(module_true);
__PACKAGE__;

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

