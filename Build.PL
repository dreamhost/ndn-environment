#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

use lib 'lib';
require Ndn::Environment::Deps;

my $build = Module::Build->new(
    module_name    => 'Ndn::Environment',
    dist_author    => 'New Dream Network',
    create_readme  => 1,
    requires       => {Ndn::Environment::Deps->requires},
    build_requires => {
        'aliased'             => 0,
        'Devel::CheckBin'     => '0.02',
        'File::chdir'         => '0.1010',
        'Test::File'          => '1.41',
        'Test::Simple'        => '0.88',
        'Test::TempDir::Tiny' => '0.003',
    },
    recursive_test_files => 1,
);

$build->create_build_script;
