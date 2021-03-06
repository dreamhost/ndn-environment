package Ndn::Environment::Builder::Cpanm;

use strict;
use warnings;

use Ndn::Environment qw/builder/;

use constant CPANM_URL =>
    'https://raw.githubusercontent.com/miyagawa/cpanminus/devel/cpanm';

use Path::Tiny;
use HTTP::Tiny;
use IO::Socket::SSL;

sub deps { () }

sub ready {  }

sub description {
    return "Download and install cpanm.";
}

sub option_details {
    return (
        rebuild => 'Rebuild cpanm even if it is already built',
    );
}

sub steps {
    my $self = shift;

    my $bin_dir = path NDN_ENV->dest, qw{ perl bin };
    my $perl = NDN_ENV->perl;

    return (
        sub {
            return if $self->args->{rebuild};
            print "Checking for cpanm...\n";
            return unless -f "$bin_dir/cpanm";
            print "cpanm already built.\n";
            return 'done';
        },
        # make sure the path exists
        sub { $bin_dir->mkpath },
        sub {

            ### get our fatpacked cpanm...
            my $res = HTTP::Tiny->new->get(CPANM_URL);

            ### result: "$res->{status} $res->{reason}"
            die 'Failed to fetch cpanm!'
                unless $res->{success};

            ### and put it in the right place...
            my $cpanm_target = path $bin_dir, 'cpanm';
            $cpanm_target->spew($res->{content});
            $cpanm_target->chmod(0755);
        },
    );
}

1;

__END__

=head1 NAME

Ndn::Environment::Builder::Cpanm - Builder for cpanm

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

