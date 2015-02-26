package Ndn::Environment::Builder::Package;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Config;

use Data::Section::Simple 'get_data_section';
use Path::Tiny;
use Template::Tiny;

sub description {
    return "Package the environment.";
}

sub option_details {
    return (
        'type=s'        => 'Package type (default: deb)',
        'name=s'        => 'Package Name',
        'maintainer=s'  => 'Who maintains the package',
        'description=s' => 'Package description',
        'depends=s'     => 'Package Dependencies',
        'version=s'     => 'Package version (defaults to timestamp)',
    );
}

sub deps { @{config->{package}->{builds} || []} }

sub steps {
    my $self = shift;

    my $pkg_dir   = NDN_ENV->pkg_dir;
    my $base_dir  = NDN_ENV->base_dir;
    my $build_dir = NDN_ENV->build_dir;
    my $dest      = NDN_ENV->dest;

    my $name  = $self->args->{'name=s'}        || config->{package}->{name}        || 'ndn-environment';
    my $maint = $self->args->{'maintainer=s'}  || config->{package}->{maintainer}  || 'nobody';
    my $desc  = $self->args->{'description=s'} || config->{package}->{description} || 'no description';
    my $deps  = $self->args->{'depends=s'}     || config->{package}->{depends};
    my $ver   = $self->args->{'version=s'}     || config->{package}->{version}->();

    my $debian_dir = path $pkg_dir, 'DEBIAN';

    chomp(my $arch = `uname -m`);
    $arch = 'amd64' if $arch eq 'x86_64';

    my $_build_control = sub {
        $self->_debian_file($debian_dir => 'control', {
            name  => $name,
            maint => $maint,
            arch  => $arch,
            ver   => $ver,
            deps  => $deps,
            desc  => $desc,
        });
    };

    my $_build_scriptlet = sub {
        $self->_debian_file($debian_dir => $_[0], {
            -mode           => 0755,
            our_pkg_dir     => path($dest),
            our_prefix      => $base_dir,
            current_symlink => path($base_dir, 'current'),
        });
    };

    return (
        sub {
            return unless config->{package}->{prebuild};
            config->{package}->{prebuild}->();
        },
        sub {
            $debian_dir->mkpath;
            path($pkg_dir, $base_dir)->mkpath;
            path($pkg_dir, $dest)->mkpath;
        },
        "rsync -avP '$dest' '$pkg_dir/$base_dir/'",
        "rm -rf '$dest'",
        $_build_control,
        sub { $_build_scriptlet->('postinst') },
        sub { $_build_scriptlet->('postrm')   },
        sub { $_build_scriptlet->('prerm')    },

        # FIXME note, this should probably be debuild
        "dpkg-deb -z8 -Zgzip --build '$pkg_dir' '$name-$ver.deb'"
    );
}

# In our templates, we currently support the following keys:
#
# * our_pkg_dir: e.g. /opt/<version>
# * current_symlink: what our current symlink should be named

sub _debian_file {
    my ($self, $debian_dir, $target_filename, $vars) = @_;
    my $mode = delete $vars->{'-mode'} || 0644;

    ### get our template, and generate: "debian/$target_filename"
    my $file     = path $debian_dir, $target_filename;
    my $template = get_data_section("debian/$target_filename");
    my $tt       = Template::Tiny->new;
    $tt->process(
        \$template,
        $vars,
        \my $output,
    );

    ### write: "$file"
    $file->spew($output);
    $file->chmod($mode);

    return;
}

1;

__DATA__

=head1 NAME

Ndn::Environment::Builder::Package - Build the environment into a package

=head1 SCRIPTLETS

We use a number of scriptlets to help control the upgrade process and maintain
symlink to a usable environment perl through the update.

At the minimum, we need to handle the following scenariaos:

=head2 install

The symlink should be created after the package files are installed.

=head2 upgrade

To minimize the amount of time we're without a usable environment perl during
upgrades, our "current" symlink needs to be moved from pointing at the old
perl to the new one after the new package's files are unpacked but before the
old package's files are deleted.

=head2 remove

The symlink should be removed after package files are removed.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

=cut

@@ debian/control
Package:      [% name %]
Priority:     optional
Section:      devel
Maintainer:   [% maint %]
Architecture: [% arch %]
Version:      [% ver  %]
Depends:      [% deps %]
Description:  [% desc %]
@@ debian/postrm
#!/bin/sh

# A post-remove scriptlet, to update our current symlink.
#
# When upgrading to a newer version, the version of this script in the old
# (aka installed) package is invoked with "upgrade" after the new version's
# files are unpacked but *before* the old files are removed.
#
# See also: https://wiki.debian.org/MaintainerScripts

set -e

if [ "$1" = "upgrade" ]; then

    # strip off the OS/level part
    _ver=`echo $2 | sed -e 's/\+.*//'`
    _new_target="[% our_prefix %]/$_ver"

    # this is suffient to ensure the symlink is pointing to the right place
    echo "Updating symlink to: $_new_target"
    rm [% current_symlink %]
    ln -sf "$_new_target" [% current_symlink %]
fi

@@ debian/postinst
#!/bin/sh

# a post-install scriptlet, to create our current symlink
#
# When installing this package on a system without a prior version installed,
# create our current symlink.
#
# See also: https://wiki.debian.org/MaintainerScripts

set -e

if [ "$1" = "configure" ]; then

    # initial package installation
    echo "Creating symlink"
    ln -sf [% our_pkg_dir %] [% current_symlink %]
fi

@@ debian/prerm
#!/bin/sh

# A pre-remove scriptlet, to remove our current symlink.
#
# When removing this package from the system (not upgrading), delete our
# current symlink before removing our files.
#
# See also: https://wiki.debian.org/MaintainerScripts

set -e

if [ "$1" = "remove" ]; then

    # outright package removal
    echo "Removing symlink"
    rm [% current_symlink %]
fi

