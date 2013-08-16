package Ndn::Environment::Builder::MyBuilder;
use strict;
use warnings;

# Register this package as a builder
use Ndn::Environment qw/builder/;

sub deps { qw/perl cpanm envpan/ }

sub description {
    return "Build Something";
}

sub option_details {
    # The keys here should be GetoptLong argument specifications.
    return (
        'debug' => 'Show cpanm output',
        'foo=s' => '...',
    );
}

sub already_installed {
    ...;
}

sub steps {
    my $self = shift;

    my $args_hash = $self->args;

    # Useful things
    my $perl     = NDN_ENV->perl;
    my $perl_dir = NDN_ENV->perl_dir;
    my $tmp      = NDN_ENV->temp;
    my $build    = NDN_ENV->build_dir;
    my $vers     = NDN_ENV->perl_version;

    return () if $self->already_installed;

    # Must return a list of codrefs and strings. Codrefs are run, strings are
    # executed as shell commands.
    return (
        "mkdir '$tmp/mystuff'",
        sub { chdir "$tmp/mystuff" },
        "...",
        "cp -r '$tmp/mystuff' '$build/mystuff'",
    );
}

1;
