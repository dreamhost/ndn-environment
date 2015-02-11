package Ndn::Environment::Config;

use v5.10;
use strict;
use warnings;

use parent 'Exporter';

use Try::Tiny;
        use Data::Dumper;

our @EXPORT = qw/config/;

sub config {
    state $CONFIG = try {
        my $content = do './env_config.pm';
        die "No config: " . ($@ || $!) unless $content;

        print Dumper($content);

        return $content;
    }
    catch {
        die "Could not load ./env_config.pm: $_";
    };

    return $CONFIG;
}

1;

__END__

=head1 NAME

Ndn::Environment::Config - Load the config file

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

