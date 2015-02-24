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

    return (
        sub {
            return unless config->{package}->{prebuild};
            config->{package}->{prebuild}->();
        },
        sub { $debian_dir->mkpath },
        "mkdir -p $pkg_dir/$base_dir",
        "mkdir -p $pkg_dir/$dest",
        "rsync -avP '$dest' '$pkg_dir/$base_dir/'",
        "rm -rf '$dest'",
        sub { $_build_control->() },

        # FIXME note, this should probably be debuild
        "dpkg-deb -z8 -Zgzip --build '$pkg_dir' '$name-$ver.deb'"
    );
}

sub _debian_file {
    my ($self, $debian_dir, $target_filename, $vars) = @_;


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

    return;
}

1;

=head1 NAME

Ndn::Environment::Builder::Package - Build the environment into a package

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

=cut

__DATA__

@@ debian/control
Package:      [% name %]
Priority:     optional
Section:      devel
Maintainer:   [% maint %]
Architecture: [% arch %]
Version:      [% ver  %]
Depends:      [% deps %]
Description:  [% desc %]
