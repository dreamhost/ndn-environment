package Ndn::Environment::Config;
use strict;
use warnings;

use v5.10;

use base 'Exporter';

our @EXPORT = qw/config/;

sub config {

    state $CONFIG = do {
        if (-e "./env_config.pm") {
            local $@ = "";
            my $cfg = do './env_config.pm';
            my $error = $@;
            unless ($cfg) {
                print STDERR "No config after loading ./env_config.pm\n";
                system('cat ./env_config.pm');
                die "No Config! ($error)\n";
            }
            use Data::Dumper;
            print "Config: " . Dumper($cfg);
        }
        else {
            die "Could not find ./env_config.pm!\n"
        }
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

