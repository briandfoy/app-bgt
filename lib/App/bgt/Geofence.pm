use v5.42;
use utf8;

package App::bgt::Geofence;

use Mojo::File;
use Mojo::DOM;
use Mojo::Util qw( dumper );

=head1 NAME

=head1 SYNOPSIS

=head1 DESCRIPTION

=cut

sub debug (@m) {
	return unless $ENV{DEBUG};
	say STDERR @m;
	}

sub extract_fences_from_kml ( $class, @files ) {
	my @fences;

	FILE: foreach my $file ( @files ) {
		unless( -e $file ) {
			warn "File <$file> does not exist. Skipping\n";
			next FILE;
			}

		my $data = Mojo::File->new($file)->slurp;
		my $dom = Mojo::DOM->new( $data );

		my $placemark = $dom->at( 'kml Document Placemark' );

		my $name = $placemark->at( 'name' )->text;
		my @coordinates =
			map { [ split /,/ ] }
			split /\s+/,
			$placemark->at( 'coordinates' )->text =~ s/\A\s+|\s+\z//gr
			;

		pop @coordinates if(
			$coordinates[0][0] eq $coordinates[-1][0]
				&&
			$coordinates[0][1] eq $coordinates[-1][1]
			);

		push @fences, $class->new(
			file => $file,
			name => $name,
			vertices => \@coordinates,
			);
		}

	return @fences;
	}

sub new ($class, %args) {
	my( $name, $vertices ) = @args{ qw(name vertices) };
	my @vertices = $vertices->@*;

	my @edges = map {
		[ map { [ $_->@[0,1] ] } @vertices[$_, $_+1] ]
		} (-1 .. $#vertices - 1);

	foreach my $edge ( @edges ) {
		my( $x0, $y0 => $x1, $y1 ) = map { $_->@* } $edge->@*;
		my $slope = ( $y1 - $y0 ) / ( $x1 - $x0 );
		my $intercept = $y0 - $slope * $x0;
		push $edge->@*, $slope, $intercept;
		}

	my %hash = ( file => $args{file}, name => $name, edges => \@edges );
	bless \%hash, $class;
	}

sub all_x ( $self ) { map { $_->[0][0], $_->[1][0] } $self->edges->@* }
sub all_y ( $self ) { map { $_->[0][1], $_->[1][1] } $self->edges->@* }

sub edges ( $self ) { $self->{edges} }

sub lowest_x  ( $self ) { $self->{lowest_x}  //= ( sort { $a <=> $b } $self->all_x )[ 0] }
sub lowest_y  ( $self ) { $self->{lowest_y}  //= ( sort { $a <=> $b } $self->all_y )[ 0] }
sub highest_x ( $self ) { $self->{highest_x} //= ( sort { $a <=> $b } $self->all_x )[-1] }
sub highest_y ( $self ) { $self->{highest_y} //= ( sort { $a <=> $b } $self->all_y )[-1] }

sub bounding_box ( $self ) {
	# add 0 to force it to be numeric when going to JSON
	$self->{bounding_box} //= [
		[ $self->lowest_x + 0,  $self->lowest_y  + 0 ],
		[ $self->highest_x + 0, $self->highest_y + 0 ],
		];
	}

sub in_bounding_box ( $self, $x, $y ) {
	$x >= $self->lowest_x && $x <= $self->highest_x
		&&
	$y >= $self->lowest_y && $y <= $self->highest_y
	}

sub is_inside ( $self, $x, $y ) {
	my $left_nodes = 0;

	debug "Threshold Y: $y";

	EDGE: foreach my $edge ( $self->edges->@* ) {
		my( $ix, $iy ) = $edge->[0]->@*;
		my( $jx, $jy ) = $edge->[1]->@*;
		my( $slope, $intercept ) = $edge->@[2,3];

		# is the edge across the Y? If not, this edge isn't important to us
		debug "Line from $ix, $iy -> $jx, $jy";
		my $crosses = ( ( $iy <= $y ) && ( $jy >= $y ) ) || ( ( $jy <= $y ) && ( $iy >= $y ) );
		if( $crosses ) {
			debug "Threshold crossed";
		} else { next EDGE };

		next unless $crosses;

		# now to see if the X coordinate of the edge at the threshold Y is on the right or left
		my $on_the_left = eval {
			my $xp = ( $y - $intercept ) / $slope;
			debug "XP: $xp";
			debug "$xp <\n$x ?";
			$xp < $x;
			};
		no warnings 'uninitialized';
		next EDGE unless $on_the_left;
		debug "XP is on the left";
		$left_nodes++;
		}

	debug "left nodes is $left_nodes";
	return $left_nodes % 2;
	}

sub fraction_inside ( $self, $points ) {
	my $inside = 0;
	foreach my $point ( $points->@* ) {
		$inside++ if $self->is_inside( $point->@{qw(lon lat)} );
		}
	return 0 if $inside == 0;
	return $inside / @$points;
	}

sub file ($self) { $self->{file} }

sub name ($self) { $self->{name} }

sub name_is ($self, $name) { $self->{name} eq $name }

no feature qw(module_true);
__PACKAGE__;
