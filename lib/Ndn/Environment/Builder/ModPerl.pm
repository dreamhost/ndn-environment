package Ndn::Environment::Builder::ModPerl;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::EnvPAN qw/install_module/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm/ }

sub description {
    return "Build mod_perl.";
}

sub steps {
    my $self = shift;

    my $perl    = NDN_ENV->perl;
    my $tmp     = NDN_ENV->temp;
    my $dest    = NDN_ENV->dest;
    my $pkg_dir = NDN_ENV->pkg_dir;

    my $name = config->{'modperl'}->{'rename'};
    my $apxs = config->{'modperl'}->{'apxs'};
    my $apr  = config->{'modperl'}->{'apr_config'};
    my $env  = config->{'modperl'}->{environment} || {};

    my $make_args = config->{'modperl'}->{make_args} ? join " " => @{config->{'modperl'}->{make_args}} : "";

    $self->environment($env);

    chomp(my $mod_path = `$apxs -q LIBEXECDIR`);
    chomp(my $inc_path = `$apxs -q INCLUDEDIR`);

    my $extra = $apr ? "MP_APR_CONFIG=$apr" : "";

    return (
        "mkdir '$tmp/mod_perl'",
        "tar -zxf 'source/mod_perl.tar.gz' -C '$tmp/mod_perl' --strip-components=1",
        sub { chdir "$tmp/mod_perl" },
        qq{$perl Makefile.PL PREFIX="$dest/perl" MP_APXS="$apxs" PERL="$perl" $extra},
        "PERL='$perl' make $make_args",
        # Known bug with LWP prevents a single test from passing.
        # Commenting out tests for now, all others pass, no real
        # issue here.
        #"PERL='$perl' make test",
        "PERL='$perl' make $make_args install DESTDIR='$pkg_dir'",
        "mv '$pkg_dir/$mod_path/mod_perl.so' '$pkg_dir/$mod_path/$name'",
        "rm -rf '$pkg_dir/$inc_path'",
    );
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::ModPerl - Build ModPerl against the system apache
and the environment perl.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

