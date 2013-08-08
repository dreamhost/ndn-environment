package Ndn::Environment::Builder::Cpanm;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Util qw/run_in_config_env/;

sub deps { qw/perl/ }

sub description {
    return "Download and install cpanm.";
}

sub option_details {
    return (
        rebuild => 'Rebuild cpanm even if it is already built',
    );
}

sub steps {
    my $self = shift;

    my $perl_dir = NDN_ENV->perl_dir;
    my $perl     = NDN_ENV->perl;
    my $vers     = NDN_ENV->perl_version;

    return (
        sub {
            return if $self->args->{rebuild};
            print "Checking for cpanm...\n";
            return unless -f "$perl_dir/bin/cpanm";
            print "cpanm already built.\n";
            return 'done';
        },
        sub {
            run_in_config_env {
				local %ENV = %ENV;
    			$ENV{PERL_MB_OPT}  = "--install_base $perl_dir";
			    $ENV{PERL_MM_OPT}  = "INSTALL_BASE=$perl_dir";
                $self->run_shell(
                    "wget -O - http://cpanmin.us | $perl - App::cpanminus",
                );
            }
        }
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

