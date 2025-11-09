use v5.42;
use utf8;

package App::bgt::GpxTools;

use Carp qw(carp);
use Data::Dumper;
use Geo::Gpx;
use List::Util qw(max min reduce);
use Math::Trig qw(deg2rad rad2deg);
use Set::CrossProduct;
use Storable qw(dclone);
use Time::Moment;

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

=head1 Class methods

=over 4

=item * new(FILE)

=cut

sub new ($class, $file) {
	my $self = bless {}, $class;
	$self->{file} = $file;
	my $message = $self->make_gpx;

	if( $message ) {
		carp $message;
		carp $self->{'eval_error'} if $self->{'eval_error'};
		return;
		}

	$self;
	}

=back

=head2 Instance methods

=over 4

=item * bounds

Returns the bounding box of the path, in degrees.

=cut

sub bounds ($self) {
	$self->summary->{'bounds'};
	}

=item * bounds_center

Returns the center of the bounding box, in degrees

=cut

sub bounds_center ($self) {
	state $key = 'bounds_center';
	return dclone $self->{$key} if defined $self->{$key};

	my $bounds = $self->bounds;
	$self->{$key} = {
		lat => ($bounds->{1}{maxlat} + $bounds->{1}{minlat}) / 2,
		lon => ($bounds->{1}{maxlon} + $bounds->{1}{minlon}) / 2,
		};

	dclone $self->{$key};
	}

=item * centers

=cut

sub centers ($self) {
	dclone $self->summary->{centers};
	}

=item * centroid

Returns the centroid (geometric center) of the path. This is the average of all
the points.

=cut

sub centroid ($self) {
	dclone $self->centers->{centroid};
	}

=item * file

Returns the original filename.

=cut

sub file ($self) { $self->{file} }

=item * geometric_median

Use's Weiszfeld's algorithm to find the geometric median of all the points in
the path.

=cut

sub geometric_median ($self) {
	state $tolerance = 1e-6;
	state $max_iterations = 1_000;

	my( $lat, $lon ) = $self->centroid->@{qw(lat lon)};

	my $iter = 0;
	ITER: while( $iter++ <= $max_iterations ) {
		my( $num_lon, $num_lat, $den ) = (0,0,0);
		my $iter_p = $self->gpx->iterate_points;
		POINT: while ( my $p = $iter_p->() ) {
			my $dist = sqrt(
				($lat - $p->{lat})**2 + ($lon - $p->{lon})**2
				);
			if( $dist == 0 ) {
				$lat = $p->{'lat'};
				$lon = $p->{'lon'};
				last ITER;
				}

			my $w = 1 / $dist;
			$num_lon += $p->{lon} * $w;
			$num_lat += $p->{lat} * $w;
			$den   += $w;
	say STDERR "iter: $iter w: $w den: $den";
			}

		my $lat_new = $num_lat / $den;
		my $lon_new = $num_lon / $den;
		my $dist_new = sqrt(
			($lat_new - $lat)**2 + ($lon_new - $lon)**2
			);
		last ITER if $dist_new < $tolerance;

		($lat, $lon) = ($lat_new, $lon_new);
		}

	{ iter => $iter, lat => $lat, lon => $lon };
	}

=item * gpx

Returns the Geo::Gpx object. If there was an error with the file, this will be
undefined.

=cut

sub gpx ($self) {
	state $key = 'gpx';
	return $self->{$key} if defined $self->{$key};

	if( defined $self->{'error'} ) {
		carp "gpx: $self->{'error'}";
		return;
		}
	}

=item * make_gpx(FILE)

Creates the L<Geo::Gpx> object for C<FILE>. You don't need to do this yourself
since C<new> will do it.

If it cannot create the object, it returns a string error message. If the problem
was with L<Geo::Gpx>, it also sets C<$self->{'eval_error'}>;

=cut

sub make_gpx ($self) {
	state $key = 'gpx';
	return $self->{$key} if defined  $self->{$key};

	my $f = $self->file;
	$self->{'error'} = do {
		if( ! -e $f ) {
			"file <$f> does not exist"
			}
		elsif( ! -r $f ) {
			"file <$f> is not readable"
			}
		elsif( ! defined eval { $self->{$key} = Geo::Gpx->new( input => $f ) } ) {
			$self->{'eval_error'} = $@;
			"file <$f> is not parseable: $@";
			}
		else { () }
		};

	return $self->{'error'};
	}

=item * summary

=cut

sub summary ($self) {
	state $key = 'summary';
	return dclone $self->{$key} if defined $self->{$key};

	return unless defined $self->gpx;

	my %summary;
	$self->{$key} = \%summary;

	my $times = $summary{'times'} = {};
	$times->{'latest'}   = { epoch => "-Inf", human => undef };
	$times->{'earliest'} = { epoch => "+Inf", human => undef };

	my $centroid = $summary{'centers'}{'centroid'} = {};

	my $bounds = $summary{'bounds'} = {};

	my @points;

	my $iter = $self->gpx->iterate_points;
	while ( my $pt = $iter->() ) {
	$self->{$key} = \%summary;
		if( exists $pt->{'time'} ) {
			$times->{'earliest'}{'epoch'} = $pt->{'time'} if $times->{'earliest'}{'epoch'} > $pt->{'time'};
			$times->{'latest'}{'epoch'}   = $pt->{'time'} if $times->{'latest'}{'epoch'}   < $pt->{'time'};
			}

		state $Re = 6_371_000;
		if( exists $pt->{'lon'} ) {
			push @points, { $pt->%* }; # Geo::Gpx has overloaded stringification

			my $lat_r = deg2rad($pt->{'lat'});
			my $lon_r = deg2rad($pt->{'lon'});

			$centroid->{'grand'}{'x'} += cos($lat_r) * cos($lon_r);
			$centroid->{'grand'}{'y'} += cos($lat_r) * sin($lon_r);
			$centroid->{'grand'}{'z'} += sin($lat_r);
			$centroid->{'grand'}{'count'} += 1;
			}
		}

	foreach my $time ( qw(earliest latest) ) {
		$times->{$time}{'human'} = Time::Moment->from_epoch( $times->{$time}{'epoch'} )->strftime('%FT%R:%S%Z');
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

	$centroid->{'point'} = {};
	foreach my $k ( qw(x y z) ) {
		$centroid->{'point'}{$k} = $centroid->{'grand'}{$k} / $centroid->{'grand'}{'count'};
		}
	$centroid->{'lon'} = rad2deg( atan2( $centroid->{'point'}{'y'}, $centroid->{'point'}{'x'} )      );
	$centroid->{'hyp'} = sqrt(    reduce { $a + $b } map { $_**2 } $centroid->{'point'}->@{qw(y x)}  );
	$centroid->{'lat'} = rad2deg( atan2( $centroid->{'point'}{'z'}, $centroid->{'hyp'} )             );

	$summary{'centers'}{'bounds'} = $self->bounds_center;
	$summary{'centers'}{'geometric_median'} = $self->geometric_median;

	# make all of these numeric for the JSON output
	$summary{'points'} = [ map { my $p = $_; $p->{$_} += 0 for keys $p->%*; $p } @points ];

	dclone $self->{$key};
	}

=item * times

=cut

sub times ($self) {
	my $times = $self->summary->{'times'};
	[ $times->@{qw(earliest latest)} ];
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

