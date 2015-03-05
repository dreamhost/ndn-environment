#!/usr/bin/perl
use strict;
use warnings;
use Module::Build;

my $build = Module::Build->new(
    module_name => 'Ndn::Environment',
    dist_author => 'New Dream Network',
    create_readme => 1,
    requires => {
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
        'MetaCPAN::API'         => 0,
        'Module::Pluggable'     => 0,
        'Path::Tiny'            => '0.061',
        'Scalar::Util'          => 0,
        'Template::Tiny'        => '1.12',
        'Try::Tiny'             => 0,
    },
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
