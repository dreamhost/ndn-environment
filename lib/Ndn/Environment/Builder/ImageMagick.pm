package Ndn::Environment::Builder::ImageMagick;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Config;

sub deps { qw/perl cpanm envpan/ }

sub description {
    return "Build ImageMagick";
}

sub option_details { return () }

sub steps {
    my $self = shift;

    my $perl  = NDN_ENV->perl;
    my $tmp   = NDN_ENV->temp;
    my $dest  = NDN_ENV->dest;

    if (-f "/$dest/imagemagick/bin/convert") {
        print "ImageMagick already installed\n";
        return ();
    }

    return (
        "mkdir '$tmp/imagemagick'",
        "tar -zxf source/ImageMagick.tar.gz -C '$tmp/imagemagick' --strip-components=1",
        sub { chdir "$tmp/imagemagick" },
        [
            './configure',
            "--prefix=$dest/imagemagick",
            "--with-perl=$perl",
        ],

        'make',
        "make install",
    );
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::ImageMagick - Builder for ImageMagick.

=head1 DESCRIPTION

This builds ImageMagick, including the perl modules.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

