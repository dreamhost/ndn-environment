package Ndn::Environment::Builder::Perl;
use strict;
use warnings;
use autodie;

use File::Temp qw/tempfile/;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Config;
use Ndn::Environment::Util qw/accessor/;

accessor outfile => sub {
    my ( $oh, $outfile ) = tempfile;
    close($oh);
    return $outfile;
};

accessor dest => sub {
    my $self = shift;
    return "perl";
};

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

    my $dest = NDN_ENV->dest . '/' . $self->dest;

    return () if $self->check_built_version($dest);

    my $cwd    = NDN_ENV->cwd;
    my $tmp    = NDN_ENV->temp;
    my $source = $self->source;

    my $outfile = $self->outfile;
    my $io = $self->args->{'verbose'} ? "" : " >> $outfile 2>&1";
    my $config_args = config->{perl}->{config_args} ? join " " => @{config->{perl}->{config_args}} : "";
    my $make_args   = config->{perl}->{make_args}   ? join " " => @{config->{perl}->{make_args}}   : "";
    my $env         = config->{perl}->{environment} || {};

    die "Dest cannot be root, really I mean it!" if !$dest || $dest =~ m{^/+$};

    $self->environment($env);

    return (
        "rm -rf $dest",
        "mkdir '$tmp/perl'",
        "tar -zxf '$source' -C '$tmp/perl' --strip-components=1",
        sub { chdir "$tmp/perl" || die "Could not chdir to temp '$tmp/perl': $!" },
        sub { return if $self->args->{'verbose'}; print "Configuring and building perl, use 'tail -f $outfile' to watch\n" },
        "./Configure -de -Dprefix='$dest' -Accflags='-fPIC' $config_args $io",
        "make $make_args $io",
        $self->args->{'skip-perl-tests'} ? () : ("make $make_args test $io"),
        "make $make_args install $io",
        sub { chdir $cwd || die "Could not chdir to working directory '$cwd': $!" },
    );
}

sub source {
    my $self    = shift;
    my $version = $self->args->{'version=s'} || config->{perl}->{version};

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
    my ($dest) = @_;

    return if $self->args->{rebuild};

    print "Checking for pre-built perl...\n";

    return unless -d $dest;

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

