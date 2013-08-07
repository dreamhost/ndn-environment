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

    my %args;
    GetOptionsFromArray(
        \@_,
        'auto_deps'    => \$args{auto_deps},
        'cpan'         => \$args{cpan},
        'debug'        => \$args{debug},
        'cpanm_args=s' => \$args{cpanm_args},
        'no_inject'    => \$args{no_inject},
    );

    inject_module(@_) unless $args{no_inject};

    for my $module (@_) {
        install_module(
            $module,
            local_lib   => '/home/cgranum/environment/build/opt/plack/perl',
            cpanm_args  => $args{cpanm_args} || '',
            auto_inject => $args{auto_deps} || 0,
            debug       => $args{debug}     || 0,
            from        => $args{cpan} ? 'cpan' : 'mirror',
        );
    }
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

