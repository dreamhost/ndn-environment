use strict;
use warnings;

use Test::More;
use Test::File;
use Test::TempDir::Tiny;
use Data::Section::Simple 'get_data_section';
use File::chdir;
use Path::Tiny;

use aliased 'Ndn::Environment::Builder::Package' => 'Builder';

# A small test, just to make sure we actually install cpanm where we expect
# it.
#
# Note (and FIXME!): we're not yet using App::Cmd::Tester as we haven't
# finished decoupling our config and other bits from the builders/commands
# yet.  This is still largely a (usable) work in progress.


my $test_target = tempdir;
my $root = path $test_target, 'root';

# set up our config file
$root->mkpath;
path($root, 'env_config.pm')->spew(get_data_section('env_config.pm'));

{
    local $CWD = "$root";

    my $pkg_dir = path $test_target, 'package';
    my $pkged_perl = path $pkg_dir, $test_target, qw{ build perl bin perl };

    ### override our paths...
    Builder->NDN_ENV->temp($test_target);
    Builder->NDN_ENV->base_dir($test_target);
    Builder->NDN_ENV->build_dir('build');
    Builder->NDN_ENV->archname('x86_64');

    # fake out our "is perl built?" checks
    my $bin_dir = Builder->NDN_ENV->bin_dir;
    $bin_dir->mkpath;
    path($bin_dir, 'perl')->touch->spew('hi there!');

    my $builder = Builder->new;
    isa_ok $builder => Builder;

    $builder->run;

    my $debian_dir = path $test_target, qw{ package DEBIAN };
    file_exists_ok "$debian_dir/control";
    file_exists_ok $pkged_perl;
    file_exists_ok "$root/ndn-environment-42.deb";
}

done_testing;

__DATA__

@@ env_config.pm
{
    testing => 1,
    package => {

        description => 'A nice, little package!',
        depends     => 'libxml2',
        version     => sub { 42 },
    },
};
