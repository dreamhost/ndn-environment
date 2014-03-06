package Ndn::Environment::Util;
use strict;
use warnings;
use feature qw/state/;

use Carp qw/croak/;
use Scalar::Util qw/blessed/;

use base 'Exporter';

our @EXPORT_OK = qw{
    new
    accessor
    accessors
    run_in_env
    run_with_config
    run_in_config_env
};

sub new {
    my $class  = shift;
    my %params = @_;

    my $self = bless {}, $class;

    for my $meth ( keys %params ) {
        next unless $self->can($meth);
        $self->$meth( delete $params{$meth} );
    }

    $self->init(%params) if $self->can('init');

    return $self;
}

sub accessor {
    my ( $name, $generator ) = @_;
    my $caller = caller;

    my $meth = sub {
        my $self = shift;
        croak "Attempt to call $name() on unblessed reference"
            unless blessed $self;

        if (@_) {
            ( $self->{$name} ) = @_;
        }
        elsif ( $generator && !exists $self->{$name} ) {
            $self->{$name} = $generator->($self);
        }

        return $self->{$name};
    };

    no strict 'refs';
    *{"$caller\::$name"} = $meth;
}

sub accessors {
    my $caller = caller;

    for my $name (@_) {
        my $meth = sub {
            my $self = shift;
            croak "Attempt to call $name() on unblessed reference"
                unless blessed $self;

            ( $self->{$name} ) = @_ if @_;

            return $self->{$name};
        };

        no strict 'refs';
        *{"$caller\::$name"} = $meth;
    }
}

sub run_in_env(&) {
    my $code = shift;

    state $in_env;
    return $code->() if $in_env;

    require Ndn::Environment;
    my $ne = Ndn::Environment->singleton;

    my $vers = $ne->perl_version;
    die "Perl has not yet been built" unless $vers;

    my $perl_dir = $ne->perl_dir;
    my $perl     = $ne->perl;
    my $tmp      = $ne->temp;
    my $dest     = $ne->dest;

    system("cp -f '$perl_dir/bin/prove' '$tmp/prove'");
    system("perl -p -i -e 's{$dest/perl}{$perl_dir}g' '$tmp/prove'") && die $!;

    if ( -e "$perl_dir/bin/cpanm" ) {
        system("cp -f '$perl_dir/bin/cpanm' '$tmp/cpanm'");
        system("perl -p -i -e 's{#!$dest/perl/bin/perl}{#!$perl}g' '$tmp/cpanm'") && die $!;
    }

    local %ENV = %ENV;

    delete $ENV{$_} for grep { m/PERL/ } keys %ENV;
    #$ENV{PERL_MB_OPT}  = "--install_base $perl_dir";
    #$ENV{PERL_MM_OPT}  = "INSTALL_BASE=$perl_dir";
    $ENV{LDFLAGS}         = "-L$perl_dir/lib/$vers/x86_64-linux/CORE";
    $ENV{LD_LIBRARY_PATH} = "$perl_dir/lib/$vers/x86_64-linux/CORE";
    $ENV{LIBRARY_PATH}    = "$perl_dir/lib/$vers/x86_64-linux/CORE";
    $ENV{CPATH}           = "$perl_dir/lib/$vers/x86_64-linux/CORE";
    $ENV{PATH}            = "$tmp:$perl_dir/bin:$ENV{PATH}";
    $ENV{PERL5LIB}        = join ':' => (
        "$perl_dir/lib/site_perl/$vers/x86_64-linux",
        "$perl_dir/lib/site_perl/$vers",
        "$perl_dir/lib/$vers/x86_64-linux",
        "$perl_dir/lib/$vers",
    );

    $in_env = 1;

    $code->();

    $in_env = 0;
}

sub run_with_config(&) {
    my $code = shift;

    state $in_config;
    return $code->() if $in_config;

    require Ndn::Environment;
    my $ne = Ndn::Environment->singleton;

    my $vers = $ne->perl_version;
    die "Perl has not yet been built" unless $vers;

    my $tmp      = $ne->temp;
    my $perl_dir = $ne->perl_dir;
    my $perl     = $ne->perl;
    my $dest     = $ne->dest;

    system("cp -f '$perl_dir/lib/$vers/x86_64-linux/Config.pm.real' '$perl_dir/lib/$vers/x86_64-linux/Config.pm'");
    system("perl -p -i -e 's{$dest/perl}{$perl_dir}g' '$perl_dir/lib/$vers/x86_64-linux/Config.pm'")
        && die "Could not munge Config.pm: $!";
    system(qq|perl -p -i -e "s{(version => '[0-9\\.]+')}{\\1,\\nstartperl => '#!$perl'}g" '$perl_dir/lib/$vers/x86_64-linux/Config.pm'|)
        && die "Could not munge Config.pm: $!";

    $in_config = 1;

    my $success = eval { $code->(); 1 };
    my $error = $@;

    system("cp -f '$perl_dir/lib/$vers/x86_64-linux/Config.pm.real' '$perl_dir/lib/$vers/x86_64-linux/Config.pm'");

    $in_config = 0;

    die $error unless $success;

    return 1;
}

sub run_in_config_env(&) {
    my $code = shift;

    run_in_env {
        run_with_config { $code->() };
    };
}

1;

__END__

=head1 NAME

Ndn::Environment::Util - Utilities

=head1 SYNOPSYS

=head1 EXPORTS

=over 4

=item new

Generic new() method so that we don't need to rewrite it everywhere or inherit
a generic base object in everything.

=item accessor 'NAME'

=item accessor NAME => sub { return DEFAULT }

Define an accessor, if a coderef is provided it will be used to generate the
default value whenever no value is defined.

=item accessors qw/NAME NAME .../

Define multiple read-write accessors at once.

=item run_in_env { ... }

Run code in the environment (environment vars altered)

=item run_with_config { ... }

Run code with a modified Config.pm

=item run_in_config_env { ... }

Run code in the environment with %ENV modified and Config.pm altered.

=back

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

