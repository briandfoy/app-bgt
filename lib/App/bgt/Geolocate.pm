#!/usr/bin/env perl
use v5.42;
use utf8;

package App::bgt::Geolocate;
use Mojo::UserAgent;
use Mojo::Util qw(dumper);

=encoding utf8

=head1 NAME

App::bgt::Geofence - deal with a surrounded area

=head1 SYNOPSIS

=head1 DESCRIPTION

=head2 Class Methods

=over 4

=item * geolocate( FILES )

=cut

$ENV{MAPQUEST_CONSUMER_KEY} = 'IBpTFuUwrP66rjT49KOVhLXpSiVLNZoK';

#say dumper( geolocate('40.667','-73.456') );

sub geolocate ($lat, $lon) {
	my %h;
	$h{'nominatum'} = nominatim($lat, $lon);
	$h{'mapquest'}  = mapquest($lat, $lon);
	return \%h;
	}

=item * ebird( LAT, LONG )

=cut

sub ebird ($lat, $lon) {
	state $url = 'https://api.ebird.org/v2/ref/hotspot/geo';
	my $query = {
		lat => $lat,
		lng => $lon,
		key => $ENV{EBIRD_KEY},
		dist => 1,
		fmt => 'json',
		};
	my $json = query( $url, $query );

	my @points =
		map { $_->[0] }
		sort { $a <=> $b }
		map {
			my $d = sqrt(
				( $_->{lat} - $lat )**2 +
				( $_->{lng} - $lon )**2
				);
			$_->{'extra'}{'lat'} = $lat;
			$_->{'extra'}{'lon'} = $lon;
			$_->{'extra'}{'distance'} = $d;
			[ $_, $d ]
			}
		$json->@*;

	{
	geo => {
		lat => $lat,
		lon => $lon,
		},
	country => $points[0]{'countryCode'},
	city    => '',
	state   => '',
	closest => $points[0],
	raw => \@points,
	}
	}

=item * mapquest( LAT, LONG )

=cut

sub mapquest ($lat, $lon) {
	# https://developer.mapquest.com/documentation/api/geocoding/reverse/get.html
	state $url = 'https://www.mapquestapi.com/geocoding/v1/reverse';
	my $query = {
		location => "$lat,$lon",
		key       => $ENV{MAPQUEST_CONSUMER_KEY},
		thumbsMap => 'false',
		outFormat => 'json',
		};

	my $json = query( $url, $query );

	my $spot = $json->{'results'}[0]{'locations'}[0];

	{
	country => $spot->{'adminArea1'},
	state   => $spot->{'adminArea3'},
	city    => $spot->{'adminArea5'},
	geo     => {
		lat => $lat,
		lon => $lon,
		},
	raw     => $json,
	}
	}

=item * nominatim( LAT, LONG )

=cut

sub nominatim ($lat, $lon) { # OpenStreetMaps
	state $url = "https://nominatim.openstreetmap.org/reverse";

	sleep 1; # for rate limiting

	my $query = {
		addressdetails => 1,
		format => 'json',
		lat => $lat,
		lon => $lon,
		};
	my $json = query( $url, $query );

	my($country, $state) = split /-/, $json->{'address'}{'ISO3166-2-lvl4'};
	{
	country => $country,
	state   => $state,
	city    => $json->{'address'}{'town'},
	geo     => {
		lat => $lat,
		lon => $lon,
		},
	raw     => $json,
	}
	}

=item * query( URL, FORM_DATA )

=cut

sub query ($url, $query) {
	ua()->get( $url => form => $query )->res->json;
	}

=item * ua()

=cut

sub ua () {
	my $ua = Mojo::UserAgent->new;
	$ua->transactor->name( __PACKAGE__ . '/1.0' );
	$ua;
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

Copyright © 2025-2026, brian d foy C<< <briandfoy@pobox.com> >>. All rights reserved.

This software is available under the Artistic License 2.0.

=cut

