package Ndn::Environment::App::Command::AddModule;

use strict;
use warnings;

use Ndn::Environment::App -command;
use Ndn::Environment::EnvPAN qw/inject_module install_module/;

sub usage_desc { "$0 addmodule Some::Module" }

sub execute {
    my ($self, $opt, $args) = @_;
    inject_module(@$args);
}

1;

__END__

=head1 NAME

Ndn::Environment::App::Command::AddModule - Command to add modules to the envpan

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

