package Ndn::Environment::Builder::Modules;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::EnvPAN qw/install_module rebuild_index/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm/ }

sub option_details {
    return (
        'auto_deps' => 'automatically fetch deps from cpan and inject them into NdnPAN',
        'cpan'      => 'Use cpan instead of NdnPAN',
        'debug'     => 'Show cpanm output',
        'cpanm_args=s' => 'Additional args to cpanm',
        'verbose'   => 'Be verbose',
    );
}

sub description {
    return "Install the modules specified in extern/modules.txt";
}

sub steps {
    my $self = shift;

    my $env = config->{modules_environment} || {};
    $self->environment($env);

    return (
        sub {
            rebuild_index();

            for my $module (@{config->{modules}}) {
                next unless $module;

                my $cpanm_args = $self->args->{'cpanm_args=s'} || "";
                $cpanm_args .= " -v" if $self->args->{'verbose'};

                if (ref $module) {
                    $cpanm_args .= " $module->{cpanm_args}";
                    $module = $module->{module};
                }

                install_module(
                    $module,
                    cpanm_args  => $cpanm_args,
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

