use strict;
use warnings;
use autodie;

# test our scriptlets on install/upgrade/remove
#
# Run actual install/upgrade/remove operations with two packages we build, and
# validate that the 'current' symlink exists/is-correct/dne properly.
#
# For implementation purposes -- and so as to not hose anyone's system --
# while also allowing for real unit tests here, we take advantage of the
# Travis CI system to do the installs on.  The Travis VM's are reset after
# each build job, so we don't need to worry about trashing anything: it's not
# going to exist a few seconds after the job completion in any case :)
#
# We implement a check to ensure we're running on Travis, as well as some
# notes to help guide future implementation work of {fake,}chroot environments
# to be able to run these tests locally.  (Local runs are not presently
# implemented, however, and likely wouldn't do anyone on fubar any good
# anyways.)

use Test::More;
use Test::File;
use Test::TempDir::Tiny;
use Capture::Tiny ':all';
use Devel::CheckBin;
use Data::Section::Simple 'get_data_section';
use File::chdir;
use Path::Tiny;

use aliased 'Ndn::Environment::Builder::Package' => 'Builder';

if ($ENV{TRAVIS_PERL_VERSION}) {

    ### we're running on travis, so can install natively for tests...
    diag 'Running on Travis; installing packages natively to test';
}
else {

    ### not on travis! see about a chroot...

    # NOTE: check for root/sudo capability here (easier to build chroots)

    # if we can't do root, we need the fake* stuff
    do { plan skip_all => "Test requires $_" unless can_run($_) }
        for qw{ fakeroot fakechroot debootstrap };

    # NOTE: build out a chroot!

    # NOTE: nix this
    plan skip_all => 'Non-travis support not yet implemented.';
}

my $test_target = tempdir;
my $root = path $test_target, 'root';

# set up our config file
$root->mkpath;
path($root, 'env_config.pm')->spew(get_data_section('env_config.pm'));

my ($v42, $v43);

subtest 'build our packages' => sub {
    local $CWD = "$root";

    my $pkg_dir = path $test_target, 'package';

    ### override our paths...
    Builder->NDN_ENV->temp($test_target);
    Builder->NDN_ENV->base_dir($test_target);
    Builder->NDN_ENV->archname('x86_64');

    my $builder = Builder->new;
    isa_ok $builder => Builder;

    my $_build = sub {

        $pkg_dir->remove_tree;

        my $build_dir = "build-$_[0]";
        my $bin_dir = path $test_target, $build_dir, qw{ perl bin };
        $bin_dir->mkpath;
        my $pkged_perl = path $pkg_dir, $test_target, $build_dir, qw{ perl bin perl };
        my $built_perl = path $bin_dir, 'perl';

        # fake out our "is perl built?" checks
        Builder->NDN_ENV->build_dir($build_dir);
        Builder->NDN_ENV->bin_dir($bin_dir);
        Builder->NDN_ENV->perl($built_perl);
        $built_perl->touch->spew('hi there!');
        $built_perl->chmod(0775);
        $builder->run;
        file_exists_ok $pkged_perl;
    };

    note 'first run';
    capture_merged { $_build->(42) };
    file_exists_ok $v42 = path "$root/ndn-environment-42.deb";
    note '...and the second';
    capture_merged { $_build->(43) };
    file_exists_ok $v43 = path "$root/ndn-environment-43.deb";
};


my $build_dir       = path $root, 'build';
my $current_symlink = path $test_target, 'current';
my $v42_target      = path $test_target, 'build-42';
my $v43_target      = path $test_target, 'build-43';

# a simple set of tests we can use to validate that our environment is what we
# expect before running the actual tests
my $_sanity = sub {
    file_not_exists_ok $_
        for $build_dir, $current_symlink, $v42_target, $v43_target;
    file_exists_ok $v42;
    file_exists_ok $v43;
};

# package install tests that we're going to run more than once
my $_install_pkg_v42 = sub {
    diag "installing $v42";
    system "sudo dpkg -i $v42";

    file_is_symlink_ok $current_symlink;
    symlink_target_exists_ok $current_symlink;
    file_exists_ok $v42_target;
    file_not_exists_ok $v43_target;
    symlink_target_is $current_symlink, $v42_target;
};

# do our package remove; ensure things look as we expect
my $_remove_pkg = sub {

    diag "removing ndn-environment";
    system 'sudo dpkg -r ndn-environment';

    file_not_exists_ok $v42_target;
    file_not_exists_ok $v43_target;
    file_not_exists_ok $current_symlink;
};

#
# first round; install w/dangling symlink, remove pkg
#

subtest 'sanity checking pre-install-with-dangling-link tests' => $_sanity;
subtest 'create dangling symlink'                              => sub {
    $current_symlink->parent->mkpath;
    symlink "$v43_target", "$current_symlink";
    file_is_symlink_ok $current_symlink;
    symlink_target_dangles_ok $current_symlink;
    symlink_target_is $current_symlink, $v43_target;
};
subtest 'validate install with dangling symlink'           => $_install_pkg_v42;
subtest 'remove package and validate'                      => $_remove_pkg;

#
# second round; full install/upgrade/remove cycle
#

subtest 'sanity checking pre-install/upgrade/remove tests'  => $_sanity;
subtest 'validate install symlink'                          => $_install_pkg_v42;
subtest 'validate installed file ownership and permissions' => sub {
    note "we have $v42 installed right now; check for that dummy perl";
    my $pkg_perl = path $v42_target, qw{ perl bin perl };
    file_exists_ok $pkg_perl;
    file_mode_is $pkg_perl, 0755;
    owner_is $pkg_perl => 'root';
    group_is $pkg_perl => 'root';
};

subtest 'validate upgrade symlink' => sub {
    diag "upgrading to $v43";
    system "sudo dpkg -i $v43";

    file_is_symlink_ok $current_symlink;
    symlink_target_exists_ok $current_symlink;
    file_not_exists_ok $v42_target;
    file_exists_ok $v43_target;
    symlink_target_is $current_symlink, $v43_target;
};

subtest 'validate remove symlink' => $_remove_pkg;

done_testing;

__DATA__

@@ env_config.pm
my $i = 42;
{
    testing => 1,
    package => {

        description => 'A nice, little package!',
        depends     => 'dpkg', # it's always there!
        version     => sub { $i++ },
    },
};
