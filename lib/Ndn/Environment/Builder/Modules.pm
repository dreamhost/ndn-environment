package Ndn::Environment::Builder::Modules;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::EnvPAN qw/install_module/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm envpan/ }

sub option_details {
    return (
        'auto_deps' => 'automatically fetch deps from cpan and inject them into NdnPAN',
        'cpan'      => 'Use cpan instead of NdnPAN',
        'debug'     => 'Show cpanm output',
        'cpanm_args=s' => 'Additional args to cpanm',
    );
}

sub description {
    return "Install the modules specified in extern/modules.txt";
}

sub steps {
    my $self = shift;

    my $perl_dir  = NDN_ENV->perl_dir;
    my $vers      = NDN_ENV->perl_version;
    my $build_dir = NDN_ENV->build_dir;

    return (
        sub {
            for my $module (@{config->{modules}}) {
                next unless $module;
                install_module(
                    $module,
                    local_lib   => '/home/cgranum/environment/build/opt/plack/perl',
                    cpanm_args  => $self->args->{'cpanm_args=s'} || '',
                    auto_inject => $self->args->{auto_deps} || 0,
                    debug       => $self->args->{debug}     || 0,
                    from        => $self->args->{cpan} ? 'cpan' : 'mirror',
                );
            }
        },
    );
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::Modules - Builder for the modules listed in the
config file.

=head1 DESCRIPTION

Will build all the modules specified in your config file.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

