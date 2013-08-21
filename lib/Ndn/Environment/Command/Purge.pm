package Ndn::Environment::Command::Purge;
use strict;
use warnings;

use Ndn::Environment;
use Ndn::Environment::CLI qw/command/;

sub short_desc { "Remove the build directory" }
sub usage      { "$0 purge" }

sub run {
    my $self = shift;

    system( 'rm -rf ' . join( '/', NDN_ENV->cwd, 'build' ) );
}

1;

__END__

=head1 NAME

Ndn::Environment::Command::Purge - Purge the build directory

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

