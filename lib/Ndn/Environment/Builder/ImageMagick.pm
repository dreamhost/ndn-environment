package Ndn::Environment::Builder::ImageMagick;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Util qw/run_in_env/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm envpan/ }

sub description {
    return "Build ImageMagick";
}

sub option_details {
    return (
    );
}

sub steps {
    my $self = shift;

    my $perl_dir = NDN_ENV->perl_dir;
    my $tmp      = NDN_ENV->temp;
    my $build    = NDN_ENV->build_dir;
    my $vers     = NDN_ENV->perl_version;

    return (
        "mkdir '$tmp/imagemagick'",
        "tar -zxf source/ImageMagick.tar.gz -C '$tmp/imagemagick' --strip-components=1",
        sub { chdir "$tmp/imagemagick" },
        sub {
            run_in_env {
                $self->run_shell(
                    [
                        './configure',
                        "--prefix=/opt/plack/imagemagick",
                        "--with-perl=$perl_dir/bin/perl",
                    ],

                    'make',
                    'make test',
                    "make install DESTDIR='$build'",
                );
            }
        },
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

