use strict;
use warnings;

use Test::More;
use Test::File;
use Test::TempDir::Tiny;
use File::chdir;

use aliased 'Ndn::Environment::Builder::Cpanm' => 'Builder';

# A small test, just to make sure we actually install cpanm where we expect
# it.
#
# Note (and FIXME!): we're not yet using App::Cmd::Tester as we haven't
# finished decoupling our config and other bits from the builders/commands
# yet.  This is still largely a (usable) work in progress.


my $test_target = tempdir;

{
    local $CWD = 't/live/cpanm';

    Builder->NDN_ENV->base_dir($test_target);
    Builder->NDN_ENV->build_dir('build');
    my $builder = Builder->new;
    isa_ok $builder => Builder;

    $builder->run;

    my $installed_cpanm = "$test_target/build/perl/bin/cpanm";
    file_exists_ok $installed_cpanm;
    file_mode_is $installed_cpanm, 0755;
}

done_testing;
