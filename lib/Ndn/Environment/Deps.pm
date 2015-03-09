package Ndn::Environment::Deps;
use strict;
use warnings;
use Config;

###########################################################
#                                                         #
# THIS SPECIFIC MODULE MAY *ONLY* DEPEND ON CORE MODULES! #
#                                                         #
###########################################################

sub requires {
    return (
        'autodie'               => '2.26',
        'parent'                => 0,
        'App::Cmd'              => '0.326',
        'Carp'                  => 0,
        'Cwd'                   => 0,
        'Data::Section::Simple' => '0.07',
        'File::Temp'            => 0,
        'Getopt::Long'          => 0,
        'HTTP::Tiny'            => '0.054',
        'IO::Socket::SSL'       => '1.56',
        'IPC::Cmd'              => 0,
        'MetaCPAN::API',        => 0,
        'Module::Pluggable'     => 0,
        'OrePAN2',              => 0,
        'Path::Tiny'            => '0.061',
        'Scalar::Util'          => 0,
        'Template::Tiny'        => '1.12',
        'Try::Tiny'             => 0,
    );
}

sub import {
    my $class = shift;
    my %args = @_;

    my $bs = $ENV{NDN_ENV_BOOTSTRAP} || $args{bootstrap};
    return 1 unless $bs;

    push @INC => 'local/lib/perl5', "local/lib/perl5/$Config{archname}";

    return 1 if check_deps(requires());

    while ($bs eq 'prompt') {
        print "\n\n*****************\n";
        print "Do you want to bootstrap Ndn::Environment? (y/N)\n";
        chomp(my $r = <STDIN>);
        next unless $r =~ m/^([yn])/i;
        return if $1 =~ m/^n/;
        last;
    }

    bootstrap();
}

sub check_deps {
    my %requires = requires();

    my $ok = 1;
    while (my ($mod, $ver) = each %requires) {
        my $installed = eval "require $mod; 1";
        unless ($installed) {
            warn $@;
            $ok = 0;
            next;
        }

        next unless $ver;

        my $sufficient = eval { $mod->VERSION($ver); 1 };
        next if $sufficient;
        warn $@;
        $ok = 0;
    }
    return $ok;
}

sub bootstrap {
    my $cpanm = find_cpanm();

    my %requires = requires();
    while (my ($mod, $ver) = each %requires) {
        my $installed = eval "require $mod; 1";
        my $sufficient = !$ver || ($installed && eval { $mod->VERSION($ver); 1 });
        next if $installed && $sufficient;
        system($^X, $cpanm, "-llocal", $mod) && die "Failed to install $mod";
    }

    return 1;
}

sub find_cpanm {
    # Is cpanm already installed?
    # IPC::Cmd core as of 5.10
    if (eval { require IPC::Cmd; 1 }) {
        my $where = IPC::Cmd::can_run('cpanm');
        if ($where && -f $where) {
            print "using system cpanm: $where\n";
            return $where;
        }
    }

    # Is the bundled one right here?
    return "bundle/cpanm" if -f "bundle/cpanm";

    # Is the bundled one close by?
    my $path = $0;
    $path =~ s{(script/)?[^/]+$}{};
    return "$path/bundle/cpanm" if -f "$path/cpanm";

    # Can we download it?
    # File::Fetch is core as of 5.10.
    if(eval { require File::Fetch; 1 }) {
        print "Attempting to download cpanm...\n";
        my $ff = File::Fetch->new(uri => 'http://xrl.us/cpanm');
        my $where = $ff->fetch(to => $ENV{TMPDIR} || '/tmp');
        if ($where && -f $where) {
            print "Downloaded to: $where\n";
            return $where;
        }
        warn $ff->error;
    }

    # :-(
    die "Could not find cpanm";
}

1;
