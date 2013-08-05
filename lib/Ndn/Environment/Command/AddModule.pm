package Ndn::Environment::Command::AddModule;
use strict;
use warnings;

use Ndn::Environment::CLI qw/command/;
use Ndn::Environment::EnvPAN qw/inject_module/;

sub short_desc { "Add a module to the EnvPAN cpan mirror" }
sub usage      { "$0 addmodule Some::Module" }

sub run {
    my $self = shift;
    my ($mod) = @_;

    inject_module(@_);
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

