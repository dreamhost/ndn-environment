package Ndn::Environment::MyCommand;
use strict;
use warnings;

# Get the 'NDN_ENV' constant
use Ndn::Environment;

# Register this package as a command
use Ndn::Environment::CLI qw/command/;

sub short_desc { "Short description for the help command" }
sub usage      { "$0 mycommand ... " }

# This is where the work gets done.
sub run {
    my $self = shift;
    my @argv = @_;

    ...;
}

1;
