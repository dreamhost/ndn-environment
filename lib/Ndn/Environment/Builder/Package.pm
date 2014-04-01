package Ndn::Environment::Builder::Package;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Config;

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

    chomp(my $arch = `uname -m`);
    $arch = 'amd64' if $arch eq 'x86_64';

    $deps = "\nDepends: $deps" if $deps;

    return (
        sub {
            return unless config->{package}->{prebuild};
            config->{package}->{prebuild}->();
        },
        "mkdir -p $pkg_dir/$base_dir",
        "mkdir -p $pkg_dir/$dest",
        "mv '$dest' '$pkg_dir/$base_dir/'",
        "cd '$pkg_dir/$base_dir/'; ln -s $build_dir/* ./",
        sub {
            mkdir("$pkg_dir/DEBIAN");
            open( my $fh, '>', "$pkg_dir/DEBIAN/control" )
                || die "Could not create control file: $!";

            print $fh <<"            EOT";
Package: $name
Priority: optional
Section: devel
Installed-Size: 100
Maintainer: $maint
Architecture: $arch
Version: ${ver}${deps}
Description: $desc
            EOT

            close($fh);
        },
        "dpkg-deb -z8 -Zgzip --build '$pkg_dir' '$name-$ver.deb'"
    );
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::Package - Build the environment into a package

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

