use v5.42;
use utf8;
no feature 'module_true';

package App::bgt::help;
use vars qw(@ISA);
push @ISA, qw(App::bgt::base);

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

	say $class->app_name, "\n";
	foreach my $name ( sort keys %commands ) {
		printf "    %-${longest}s  -  %s\n", $name, $commands{$name};
		}

	}

sub description ($class) {
	"outputs the help message and exits";
	}

__PACKAGE__;
