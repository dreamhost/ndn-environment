package Ndn::Environment::Command::Help;
use strict;
use warnings;

use Ndn::Environment::CLI qw/command/;

sub short_desc { "Get command help" }
sub usage      { "$0 help COMMAND" }

sub run {
    my $self = shift;
    my ($command) = @_;

    if ($command) {
        print "Usage: " . $self->CLI->command($command)->usage;
        return;
    }

    print "Usage: $0 COMMAND [OPTIONS]\n\nCommands:\n";
    for my $cm ( sort $self->CLI->commands ) {
        printf "    %-14s %s\n", $cm, $self->CLI->command($cm)->short_desc;
    }
}

1;

__END__

=head1 NAME

Ndn::Environment::Command::Help - Command to get help

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

