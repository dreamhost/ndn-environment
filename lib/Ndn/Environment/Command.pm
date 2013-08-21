package Ndn::Environment::Command;
use strict;
use warnings;
use feature qw/state/;

use Ndn::Environment::Util qw/new/;
require Ndn::Environment::Command;

sub short_desc { "No description." }
sub usage      { "No help available." }

sub run {
    my $self = shift;
    die $self->command . " Does not implement run!";
}

1;

__END__

=head1 NAME

Ndn::Environment::Command - Base class for commands

=head1 WRITING A NEW COMMAND

	package Ndn::Environment::Command::MyCommand;
	use strict;
	use warnings;
	
	use Ndn::Environment;
	use Ndn::Environment::CLI qw/command/;
	
	sub short_desc { "This is my command" }
	sub usage      { "$0 mycommand [ARGS]" }
	
	sub run {
	    my $self = shift;
		my @argv = @_;
		...
	}
	
	1;

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

