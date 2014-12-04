package Ndn::Environment::Config;
use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw/config/;
our $CONFIG;

sub config { $CONFIG };

if (-e "./env_config.pm") {
    $CONFIG = do './env_config.pm';
    die "No Config! ($@)" unless $CONFIG;
}
else {
    die "Could not find ./env_config.pm!\n"
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

