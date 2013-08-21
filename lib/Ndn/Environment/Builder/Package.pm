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

sub deps { @{config->{package_builds}} }

sub steps {
    my $self = shift;

    my $build = NDN_ENV->build_dir;

    my $name  = $self->args->{'name=s'}        || config->{package_name}        || 'ndn-environment';
    my $maint = $self->args->{'maintainer=s'}  || config->{package_maintainer}  || 'nobody';
    my $desc  = $self->args->{'description=s'} || config->{package_description} || 'no description';
    my $deps  = $self->args->{'depends=s'}     || config->{package_depends};
    my $ver   = $self->args->{'version=s'}     || config->{package_version}->();

	chomp(my $arch = `uname -m`);
	$arch = 'amd64' if $arch eq 'x86_64';

	$deps = "\nDepends: $deps" if $deps;

    return (
        sub {
            mkdir("$build/DEBIAN");
            open( my $fh, '>', "$build/DEBIAN/control" )
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
        "dpkg-deb -z8 -Zgzip --build '$build' '$name-$ver.deb'"
    );
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

