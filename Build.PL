#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Ndn::Environment',
    dist_author => 'New Dream Network',
    create_readme => 1,
    requires => {
        'autodie'           => '2.26',
        'parent'            => 0,
        'App::Cmd'          => '0.326',
        'Carp'              => 0,
        'Cwd'               => 0,
        'File::Temp'        => 0,
        'Getopt::Long'      => 0,
        'Module::Pluggable' => 0,
        'Scalar::Util'      => 0,
        'Try::Tiny'         => 0,
    },
    build_requires => {
        'Test::Simple' => '0.88',
    },
);

$build->create_build_script;
