package Ndn::Environment::App::Command::Build;

use strict;
use warnings;

use Ndn::Environment::App -command;

use Ndn::Environment;
use Ndn::Environment::Util qw/accessor/;

sub short_desc { "Build an environment" }

sub usage_desc {
    my $self = shift;

    my $items = join "" => map { $self->builder_usage($_) } sort $self->NDN_ENV->builders;

    my $out = <<"    EOT";
$0 build [ITEM] [Options]

Available Items:
$items
    EOT
}

sub builder_usage {
    my $self = shift;
    my ($name) = @_;

    my $builder     = $self->NDN_ENV->builder($name);
    my $description = $builder->description;
    my $options     = join "\n" => map { $self->option_string( $builder, $_ ) } $builder->options;

    $options = $options ? <<"    EOT" : "";
  Options:
$options
    EOT

    return <<"    EOT";
  * $name
    $description
    $options
    EOT
}

sub option_string {
    my $self = shift;
    my ( $builder, $option ) = @_;

    return sprintf( "        --%-10s %s", $option, $builder->option_usage($option) );
}

sub execute {
    my ($self, $opt, $args) = @_;
    my ( $item, @args ) = @$args;
    die "Nothing to build.\n" unless $item;

    my $last = $self->NDN_ENV->builder($item);

    die "I do not know how to build '$item'\n"
        unless $last;

    my @deps = sort dep_sorter $self->builders($item);
    print "Finding Dependencies: " . join ", " => map { $_->[0] } @deps;
    for my $set (@deps) {
        print "\n=========\nBuilding: $set->[0]\n";
        $set->[1]->new(@args)->run;
    }
}

accessor seen => sub { {} };

sub builders {
    my $self = shift;
    my ($item) = @_;
    return if $self->seen->{$item}++;

    my $class = $self->NDN_ENV->builder($item);
    die "build-item '$item' has no class!" unless $class;
    my @all = ( [$item => $class] );

    for my $dep ( $class->all_deps ) {
        push @all => $self->builders($dep);
    }

    return @all;
}

sub dep_sorter($$) {
    my ( $a, $b ) = @_;

    my $adeps = [$a->[1]->deps];
    my $bdeps = [$b->[1]->deps];

    # If neither have deps then it does not matter.
    return 0 unless @$adeps || @$bdeps;

    my $a_in_b = grep { m/$a->[0]/ } @$bdeps;
    my $b_in_a = grep { m/$b->[0]/ } @$adeps;
    die "Circular dependencies! $a->[0], $b->[0]\n"
        if $a_in_b && $b_in_a;

    return 1  if $b_in_a;
    return -1 if $a_in_b;

    return 1  if @$adeps && !@$bdeps;
    return -1 if @$bdeps && !@$adeps;

    return 0;
}

1;

__END__

=head1 NAME

Ndn::Environment::App::Command::Build - Command to build things.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

