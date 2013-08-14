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

    my $build = NDN_ENV->build_dir;

    return ( "rsync -avP static/* $build/" );
}

1;

__END__

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

