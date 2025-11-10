#!/usr/bin/env perl
use v5.42;
use utf8;

package App::bgt::Geolocate;
use Mojo::UserAgent;
use Mojo::Util qw(dumper);

$ENV{MAPQUEST_CONSUMER_KEY} = 'IBpTFuUwrP66rjT49KOVhLXpSiVLNZoK';

say dumper( geolocate('40.667','-73.456') );

sub geolocate ($lat, $lon) {
	my %h;
	$h{'nominatum'} = nominatim($lat, $lon);
	$h{'mapquest'}  = mapquest($lat, $lon);
	return \%h;
	}

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
	country => $point[0]{'countryCode'}
	city    =>
	state   =>
	closest => $point[0],
	raw => \@points,
	}
	}

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

sub query ($url, $query) {
	ua()->get( $url => form => $query )->res->json;
	}

sub ua () {
	my $ua = Mojo::UserAgent->new;
	$ua->transactor->name( __PACKAGE__ . '/1.0' );
	$ua;
	}

no feature qw(module_true);
__PACKAGE__;
