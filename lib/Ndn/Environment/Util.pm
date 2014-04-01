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

=back

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

