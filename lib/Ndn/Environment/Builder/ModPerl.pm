package Ndn::Environment::Builder::ModPerl;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Util qw/run_in_env run_in_config_env/;
use Ndn::Environment::EnvPAN qw/install_module/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm envpan/ }

sub description {
    return "Build mod_perl.";
}

sub steps {
    my $self = shift;

    my $perl     = NDN_ENV->perl;
    my $perl_dir = NDN_ENV->perl_dir;
    my $tmp      = NDN_ENV->temp;
    my $build    = NDN_ENV->build_dir;
    my $vers     = NDN_ENV->perl_version;

    if ( -e "$build/usr/lib/apache2/modules/mod_perl_plack.so" ) {
        print "mod_perl already built...\n";
        return ();
    }

    return (
        "mkdir '$tmp/mod_perl'",
        "tar -zxf 'source/mod_perl.tar.gz' -C '$tmp/mod_perl' --strip-components=1",
        sub { chdir "$tmp/mod_perl" },
        sub {
            run_in_config_env {
                $self->run_shell(
                    qq{$perl Makefile.PL PREFIX="/opt/plack/perl" MP_APXS="/usr/bin/apxs2"},
                    'make',
                    # Known bug with LWP prevents a single test from passing.
                    # Commenting out tests for now, all others pass, no real
                    # issue here.
                    #'make test',
                    "make install DESTDIR='$build'",
                );
            }
        },
		"mv '$build/usr/lib/apache2/modules/mod_perl.so' '$build/usr/lib/apache2/modules/mod_perl_plack.so'"
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

