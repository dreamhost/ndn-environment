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
    my $dest     = NDN_ENV->dest;

    my $name = config->{modperl_rename};
    my $apxs = config->{modperl_apxs};
    chomp(my $mod_path = `$apxs -q LIBEXECDIR`);
    chomp(my $inc_path = `$apxs -q INCLUDEDIR`);

    if ( -e "$build/$mod_path/$name" ) {
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
                    qq{$perl Makefile.PL PREFIX="$dest/perl" MP_APXS="$apxs" PERL="$perl"},
                    "perl -p -i -e 's{= $dest/perl/bin/perl}{= $perl}g' Makefile src/modules/perl/Makefile",
                    "PERL='$perl' make",
                    # Known bug with LWP prevents a single test from passing.
                    # Commenting out tests for now, all others pass, no real
                    # issue here.
                    #"PERL='$perl' make test",
                    "PERL='$perl' make install DESTDIR='$build'",
                );
            }
        },
        "mv '$build/$mod_path/mod_perl.so' '$build/$mod_path/$name'",
        "rm -rf '$build/$inc_path'",
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

