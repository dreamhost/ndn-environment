package Ndn::Environment::CLI;
use strict;
use warnings;
use feature qw/state/;

use Ndn::Environment;
use Ndn::Environment::Command;
use Ndn::Environment::Util qw/accessors accessor/;

use Module::Pluggable
    sub_name    => 'load_plugins',
    search_path => 'Ndn::Environment::Command',
    require     => 1;

accessor command_list => sub { {} };

sub import {
    my $class  = shift;
    my ($arg)  = @_;
    my $caller = caller();

    my $self = $class->singleton;

    if ( $arg && $arg eq 'command' ) {
        $self->push_command($caller);
        no strict 'refs';
        push @{"$caller\::ISA"} => 'Ndn::Environment::Command';
    }

    {
        no strict 'refs';
        *{"$caller\::CLI"} = sub { $self };
    }

    return 1;
}

sub singleton {
    my $class = shift;

    state $singleton;
    $singleton ||= Ndn::Environment::Util::new($class);

    return $singleton;
}

sub push_command {
    my $self     = shift;
    my ($module) = @_;
    my @parts    = split /::/, $module;
    my $command  = lc( $parts[-1] );

    $self->command_list->{$command} = $module;
}

sub commands {
    my $self = shift;
    return keys %{$self->command_list};
}

sub command {
    my $self = shift;
    my ($command) = @_;
    return unless $self->command_list->{$command};
    return $self->command_list->{$command}->new;
}

sub run {
    my $self = shift;
    my ( $command, @args ) = @_;
    $command ||= 'help';

    my $ci = $self->command($command);

    die "'$command' is not a valid command.\n"
        unless $ci;

    return $ci->run(@args);
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

