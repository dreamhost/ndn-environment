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

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

