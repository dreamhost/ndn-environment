package Ndn::Environment::Builder::ModPSGI;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Util qw/run_in_env run_in_config_env/;
use Ndn::Environment::EnvPAN qw/install_module/;
use Ndn::Environment::Config;

our @MODULE_DEPS = (
    'Test::Base',
    'Plack::Test::Suite',
    'YAML',
    'LWP::UserAgent',
    'Path::Class',
);

sub deps { qw/perl cpanm envpan/ }

sub description {
    return "Build mod_psgi.";
}

sub option_details {
    return (
        'clone=s'   => 'use git to clone the mod_psgi repo specified',
        'cpan'      => 'automatically download the cpan dependencies',
        'auto_deps' => 'automatically fetch deps from cpan and inject them into NdnPAN',
        'debug'     => 'Show cpanm output',
    );
}

sub steps {
    my $self = shift;

    my $perl_dir = NDN_ENV->perl_dir;
    my $tmp      = NDN_ENV->temp;
    my $build    = NDN_ENV->build_dir;
    my $vers     = NDN_ENV->perl_version;

    if ( -e "$build/usr/lib/apache2/modules/mod_psgi.so" ) {
        print "mod_psgi already built...\n";
        return ();
    }

    my $repo =
           $self->args->{'clone=s'}
        || config->{mod_psgi_src}
        || die "No git repo specified, no source to build.";

    return (
        sub {
            for my $module (@MODULE_DEPS) {
                install_module(
                    $module,
                    auto_inject => $self->args->{auto_deps} || 0,
                    debug       => $self->args->{debug}     || 0,
                    from => $self->args->{cpan} ? 'cpan' : 'mirror'
                );
            }
        },
        "git clone $repo '$tmp/mod_psgi'",
        sub { chdir "$tmp/mod_psgi" },
        'autoreconf',
        sub {
            run_in_env {
                $self->run_shell(
                    [
                        './configure',
                        '--with-apxs=/usr/bin/apxs2',
                        '--with-apachectl=/usr/sbin/apachectl',
                        "--with-perl=$perl_dir/bin/perl",
                        "--with-prove=$tmp/prove",
                    ],

                    'make',
                    'make test',
                    "make install DESTDIR='$build'",
                );
            }
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

