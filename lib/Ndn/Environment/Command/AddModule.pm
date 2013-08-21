package Ndn::Environment::Command::AddModule;
use strict;
use warnings;

use Ndn::Environment::CLI qw/command/;
use Ndn::Environment::EnvPAN qw/inject_module install_module/;
use Getopt::Long qw(GetOptionsFromArray);

sub short_desc { "Add a module to the EnvPAN cpan mirror" }
sub usage      { "$0 addmodule Some::Module" }

sub run {
    my $self = shift;
    inject_module(@_);
}

1;

__END__

=head1 NAME

Ndn::Environment::Command::AddModule - Command to add modules to the envpan

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

