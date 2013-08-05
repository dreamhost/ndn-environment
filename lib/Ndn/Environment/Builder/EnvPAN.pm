package Ndn::Environment::Builder::EnvPAN;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Util qw/run_in_env/;
use Ndn::Environment::EnvPAN qw/install_module inject_module/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm/ }

sub description {
    return "Build the modules necessary to use EnvPAN.";
}

sub steps {
    my $self = shift;

    my $perl_dir = NDN_ENV->perl_dir;
    my $perl     = NDN_ENV->perl;
    my $vers     = NDN_ENV->perl_version;
    my $cwd      = NDN_ENV->cwd;

    return (
        sub {
            my $built = 1;
            $built &&= -e "envpan/lib/perl5/OrePAN2.pm";
            $built &&= -e "envpan/lib/perl5/MetaCPAN/API.pm";
            if ($built) {
                print "EnvPAN already built...\n";
                return;
            }

            mkdir('envpan');
            mkdir('envpan/lib');
            mkdir('envpan/lib/perl5');

            print "Bootstrapping envpan from cpan, these modules WILL NOT be added to your environment.\n";
            install_module( 'OrePAN2',       from => 'cpan', local_lib => "$cwd/envpan");
            install_module( 'MetaCPAN::API', from => 'cpan', local_lib => "$cwd/envpan");

            print "Adding your env_config.pm modules to envpan.\n";
            inject_module(@{config->{modules}});
        },
    );
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

