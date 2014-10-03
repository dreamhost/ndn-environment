package Ndn::Environment::Builder::EnvPAN;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::EnvPAN qw/install_module inject_module/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm/ }

sub description {
    return "Build the modules necessary to use EnvPAN.";
}

sub steps {
    my $self = shift;

    my $perl = NDN_ENV->perl;
    my $cwd  = NDN_ENV->cwd;

    return (
        sub {
            mkdir('envpan');
            mkdir('local');
            mkdir('local/lib');
            mkdir('local/lib/perl5');

            print "Bootstrapping envpan from cpan, these modules WILL NOT be added to your environment.\n";
            install_module('Mouse',                  from => 'cpan', local_lib => "$cwd/local");
            install_module('WWW::Mechanize::Cached', from => 'cpan', local_lib => "$cwd/local");
            install_module('MetaCPAN::Client',       from => 'cpan', local_lib => "$cwd/local");
            install_module('MetaCPAN::API',          from => 'cpan', local_lib => "$cwd/local");
            install_module('OrePAN2',                from => 'cpan', local_lib => "$cwd/local");

            # Do not inject if we have an authors dir
            return if -d "envpan/authors";

            print "Adding your env_config.pm modules to envpan.\n";
            inject_module(map {ref $_ ? $_->{module} : $_} @{config->{modules}});
        },
    );
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::EnvPAN - Build the local darkpan.

=head1 DESCRIPTION

Builds ./envpan as a darkpan mirror, injects all the modules listed int he
config file. Also creates a local::lib for any dependencies needed to build
and/or use the envpan.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

