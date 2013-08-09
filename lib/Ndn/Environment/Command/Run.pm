package Ndn::Environment::Command::Run;
use strict;
use warnings;

use Ndn::Environment::CLI qw/command/;
use Ndn::Environment::Util qw/run_in_config_env/;

sub short_desc { "Run the build perl" }
sub usage      { "$0" }

sub run {
    my $self = shift;

	my $ne = Ndn::Environment->singleton;
    my $perl = $ne->perl;

	run_in_config_env {
		system( $perl ) && die $!;
	}
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

