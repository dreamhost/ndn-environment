package Ndn::Environment::Builder::Perl;
use strict;
use warnings;
use File::Temp qw/tempfile/;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Config;
use Ndn::Environment::Util qw/accessor/;

accessor outfile => sub {
    my ( $oh, $outfile ) = tempfile;
    close($oh);
    return $outfile;
};

sub dest { '/opt/plack/perl' }

sub description {
    return "Build a perl install.";
}

sub option_details {
    return (
        'rebuild'         => 'Rebuild perl even if it is already built',
        'version=s'       => 'Download the specified perl verson',
        'verbose'         => 'Show complete perl build output',
        'skip-perl-tests' => 'Do not run "make test" when building perl',
    );
}

sub ready { 1 }

sub on_error {
    my $self = shift;
    return if $self->args->{'verbose'};
    my $outfile = $self->outfile;
    system( "cat $outfile" );
}

sub steps {
    my $self = shift;

    return () if $self->check_built_version();

    my $cwd    = NDN_ENV->cwd;
    my $tmp    = NDN_ENV->temp;
    my $build  = NDN_ENV->build_dir;
    my $source = $self->source;
    my $dest   = $self->dest;

    my $outfile = $self->outfile;
    my $io = $self->args->{'verbose'} ? "" : " >> $outfile 2>&1";
    my $config_args = config->{perl_config_args} || '';

    return (
        "mkdir '$tmp/perl'",
        "tar -zxf '$source' -C '$tmp/perl' --strip-components=1",
        sub { chdir "$tmp/perl" || die "Could not chdir to temp '$tmp/perl': $!" },
        sub { return if $self->args->{'verbose'}; print "Configuring and building perl, use 'tail -f $outfile' to watch\n" },
        "./Configure -de -Dprefix='$dest' -Accflags='-fPIC' $config_args $io",
        "make $io",
        $self->args->{'skip-perl-tests'} ? () : ("make test $io"),
        "make install DESTDIR='$build' $io",
        sub {
            my $perl_dir = NDN_ENV->perl_dir;
            my $vers     = NDN_ENV->perl_version;
            die "Could not find perl verson." unless $vers;
            $self->run_shell(
                "ln -s '$perl_dir/lib/site_perl/$vers' '$perl_dir/lib/perl5'",
                "cp '$perl_dir/lib/$vers/x86_64-linux/Config.pm' '$perl_dir/lib/$vers/x86_64-linux/Config.pm.real'",
            );
        },
        sub { chdir $cwd || die "Could not chdir to working directory '$cwd': $!" },
    );
}

sub source {
    my $self    = shift;
    my $version = $self->args->{'version=s'} || config->{perl_version};

    die "No perl version specified, and no source/perl.tar.gz file provided"
        unless $version || -e 'source/perl.tar.gz';

    return 'source/perl.tar.gz' unless $version;

    my $perl = "perl-$version.tar.gz";
    my $file = "source/$perl";

    $self->run_shell("wget http://www.cpan.org/src/5.0/$perl -O $file")
        unless -e $file;

    return $file;
}

sub check_built_version {
    my $self = shift;

    print "Checking for pre-built perl...\n";

    return
        unless NDN_ENV->perl_version
        && !$self->args->{rebuild};

    print "Perl already built, not rebuilding.\n";
    return 'done';
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::Perl - Builder that configures and compiles the
environments perl.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

