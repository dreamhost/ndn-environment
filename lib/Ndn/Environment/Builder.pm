package Ndn::Environment::Builder;
use strict;
use warnings;

use Getopt::Long qw(GetOptionsFromArray);

use Ndn::Environment::Util qw/accessors accessor/;
use Ndn::Environment;

accessor args => sub { {} };
accessor argv => sub { [] };

sub new {
    my $class = shift;
    my @argv  = @_;

    my %options = $class->option_details;

    my $self = bless {}, $class;
    my $args = $self->args;

    GetOptionsFromArray(
        \@argv,
        map { $_ => \$args->{$_} } keys %options
    );

    $self->argv( \@argv );

    return $self;
}

sub deps {}

sub option_details { }

sub description { 'No description' }

sub all_deps {
    my $self = shift;
    my @deps = $self->deps;

    for my $dep ($self->deps) {
        my $class = $self->NDN_ENV->builder($dep);
        push @deps => $class->all_deps;
    }

    my %seen;
    return grep { !$seen{$_}++ } @deps;
}

sub options {
    my $class   = shift;
    my %details = $class->option_details;
    return map { "$_" } keys %details;
}

sub option_usage {
    my $class = shift;
    my ($option) = @_;

    my %details = $class->option_details;
    return $details{$option} || "No description.";
}

sub steps { }
sub on_error { }

sub ready {
    my $self = shift;
    die "Perl does not appear to be built"
        unless NDN_ENV->perl_version;
}

sub run {
    my $self = shift;
    chdir( NDN_ENV->cwd );
    $self->ready;

    for my $step ( $self->steps ) {
        if ( ref $step && ref $step eq 'CODE' ) {
            my $ret = $step->($self);
            return if $ret && $ret eq 'done';
        }
        else {
            $self->run_shell($step);
        }
    }
}

sub run_shell {
    my $self = shift;
    for my $step (@_) {
        my @step = ref $step ? @$step : ($step);

        if (system(@step)) {
            $self->on_error;
            die "Error running " . join( ' ', @step ) . "\n(last \$! (may not be useful): $!)";
        }
    }
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder - Base class for builders

=head1 CUSTOM BUILDER

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

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

