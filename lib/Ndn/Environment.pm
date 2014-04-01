package Ndn::Environment;
use strict;
use warnings;
use feature qw/state/;

our $VERSION = "1.000";

use Ndn::Environment::Util qw/accessors accessor/;
use Ndn::Environment::Config;

use File::Temp qw/tempdir/;
use Cwd qw/getcwd/;
use Module::Pluggable
    sub_name    => 'load_plugins',
    search_path => 'Ndn::Environment::Builder',
    require     => 1;

accessors qw/cwd/;

accessor builder_list => sub { {} };

accessor temp => sub {
    my $temp = tempdir( CLEANUP => 0 );

    print "Using temp dir: $temp\n";

    return $temp;
};

accessor pkg_dir => sub {
    my $self = shift;
    my $tmp = $self->temp;
    return "$tmp/package";
};

sub import {
    my $class  = shift;
    my ($arg)  = @_;
    my $caller = caller();

    my $self = $class->singleton;

    if ( $arg && $arg eq 'builder' ) {
        require Ndn::Environment::Builder;
        $self->push_builder($caller);
        no strict 'refs';
        push @{"$caller\::ISA"} => 'Ndn::Environment::Builder';
    }

    {
        no strict 'refs';
        *{"$caller\::NDN_ENV"} = sub { $self };
    }

    return 1;
}

sub singleton {
    my $class = shift;

    state $singleton;
    $singleton ||= Ndn::Environment::Util::new($class);

    return $singleton;
}

sub init {
    my $self   = shift;
    my %params = @_;

    $self->cwd( getcwd() );
}

sub push_builder {
    my $self     = shift;
    my ($module) = @_;
    my @parts    = split /::/, $module;
    my $builder  = lc( $parts[-1] );

    $self->builder_list->{$builder} = $module;
}

sub builders {
    my $self = shift;
    return keys %{$self->builder_list};
}

sub builder {
    my $self = shift;
    my ($builder) = @_;
    return $self->builder_list->{$builder};
}

sub base_dir {
    my $self = shift;
    return unless config;
    my $base = $ENV{ENV_DEST} || config->{dest_dir} || "/opt/penv";
    return $base;
}

accessor build_dir => sub {
    my $self = shift;
    my $build = $ENV{ENV_BUILD} || config->{build}->();
    return $build;
};

sub dest {
    my $self = shift;
    return unless config;

    state $out;
    unless($out) {
        my $base = $self->base_dir;
        my $build = $self->build_dir;
        $out = "$base/$build";
    }

    return $out;
}

sub perl {
    my $self = shift;
    my $dest = $self->dest;
    my $bin_dir = $self->dest . '/perl/bin';
    return "$bin_dir/perl";
}

sub cpanm {
    my $self = shift;
    my $dest = $self->dest;
    my $bin_dir = $self->dest . '/perl/bin';
    return "$bin_dir/cpanm";
}

sub archname {
    my $self = shift;

    my $perl = $self->perl;
    return unless -f $perl;

    my ($archname) = `$perl -V:archname` =~ /='([^']+)'/;

    return $archname;
}

1;

__END__

=pod

=head1 NAME

Ndn::Environment - Configure, Build and Package an encapsulated perl production
environment.

=head1 DESCRIPTION

Ndn-Environment is a tool for building a consistent and controlled production
perl environment (with a focus on Plack/PSGI). You specify a perl version, a
list of modules, as well as other build items, Ndn-Environment then builds the
perl, modules, and items of your choice into a 'build' that can then be easily
packaged and distributed to your servers.

Ndn-Environment has a goal of being like perlbrew for production environments.
Perlbrew is awesome for development, but is not currently suited for all
production environments (such as embedded perl with mod_perl or mod_psgi).

=head1 COMPATABILITY

This module was assembled quickly to meet a need, as such many shortcuts were
taken. For example it makes many calls to the shell to munge files and move
things around. Most of these shortcuts are compatible across linux
distributions, but will undoubtedly break for windows. Some other shortcuts are
ubuntu specific.

The ModPSGI build task assumes ubuntu's apache2 and apache2-prefork-dev modules
are used.

B<This code is being released into the open-source community in hopes that
other people may find it useful.> It is hoped that others may contribute work
to make this package build production environments across many distributions,
or even operating systems.

Part of the quick assembly also means that only minimal unit testing has been
written. Most of the code is difficult to unit test as it depends on shell
commands. This is not an ideal situation, and will be rectified in the future.

In the end this is a script that outgrew its status as a script and became a
build system.

=head1 SYNOPSIS

=head2 CLI USAGE

=head3 QUICK AND DIRTY

Create a new environment build:

    $ ndn_env init my_env
    New Ndn-Environment directory initialized: my_env
    $ cd my_env

Configure the build (config file is documented)

    $ vim env_config.pm

At this point you may wish to turn the build directory into a git repository:

    $ git init .
    $ git add .
    $ git commit -m"Initial Commit"

Build the specified perl-version, perl-module, and anything else
configured, then produce a package. What items get built for the package
is configured in env_config.pm in the project root.

    $ ndn_env build package

=head3 ADDING MODULES

Ndn-Environment uses a local cpan mirror called envpan. envpan is built using
L<OrePAN2>. In order for a module to be installed to your environment it must
be added to envpan. Any module listed in the config file will be automatically
fetched from cpan and injected into envpan. B<Dependencies are not fetched!>.

Adding modules to envpan by hand

    $ ndn_env addmodule Some::Module
    $ ndn_env addmodule Some-Module.tar.gz
    $ ndn_env addmodule http://.../Some-Module.tar.gz
    $ ndn_env addmodule git://...

Adding modules the easy way:

    $ ndn_env build modules --auto_deps

This will automatically fetch dependencies and inject them into envpan. All
future builds will use the versions already fetched, this guarentees that after
the first build your environment will always be consistent, modules will only
be upgraded if you re-add them.

=head3 GETTING HELP

    # List commands:
    $ ndn_env help

    # Get help for a command
    $ ndn_env help COMMAND

=head2 API

Using this module will import 'NDN_ENV' which returns the singleton instance.

	use Ndn::Environment;

	my $perl = NDN_ENV->perl;

Or if you are making a builder:

	use Ndn::Environment 'builder';

See L<Ndn::Environment::Builder>

=head1 METHODS

=over 4

=item $e = $e->singleton

Get the singleton

=item $class = $e->builder($NAME)

Get the package for the specified builder

=item $dir = $e->temp

Get the current temp directory.

=item $e->load_plugins

Load all the builder plugins.

=item $e->push_builder($CLASS)

Add a builder.

=item $href = $e->builder_list

Get the C<name => class> hashref of builders

=item @list = $e->builders

Get a list of all builder names.

=back

=head1 AUTHORS

=over 4

=item Chad Granum L<exodist7@gmail.com>

=back

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

