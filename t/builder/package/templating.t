use strict;
use warnings;

use Test::More;
use Test::TempDir::Tiny;
use Test::File;

use Data::Section::Simple 'get_data_section';
use Path::Tiny;

use aliased 'Ndn::Environment::Builder::Package';

my $pkg = Package->new();
isa_ok $pkg => Package;

my $dir = tempdir;

$pkg->_debian_file($dir => 'control', {
    name  => 'pkg-name',
    maint => 'Captain Jack Harkness',
    arch  => 'here',
    ver   => 'there',
    deps  => 'stuff, more-stuff',
    desc  => 'yaaaaaay',
});

my $file = path($dir, 'control');
file_exists_ok($file);

is $file->slurp => get_data_section('debian/control'),
    'debian/control looks good!';

done_testing;

__DATA__

@@ debian/control
Package:      pkg-name
Priority:     optional
Section:      devel
Maintainer:   Captain Jack Harkness
Architecture: here
Version:      there
Depends:      ${shlibs:Depends}, stuff, more-stuff
Description:  yaaaaaay
