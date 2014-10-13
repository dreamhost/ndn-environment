package Ndn::Environment::Builder::Static;
use strict;
use warnings;

use Ndn::Environment qw/builder/;
use Ndn::Environment::Config;

sub deps { qw// }

sub description {
    return "Build static files.";
}

sub steps {
    my $self = shift;

    my $pkg_dir   = NDN_ENV->pkg_dir;
    my $base_dir  = NDN_ENV->base_dir;
    my $build_dir = NDN_ENV->build_dir;

    return ( "rsync -avP static/* $pkg_dir/$base_dir/$build_dir/" );
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::Static - Copy static files from the 'static'
directory into the build directory.

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

