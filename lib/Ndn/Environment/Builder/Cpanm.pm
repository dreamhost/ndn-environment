package Ndn::Environment::Builder::Cpanm;
use strict;
use warnings;

use Ndn::Environment qw/builder/;

sub deps { qw/perl/ }

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

    my $dest = NDN_ENV->dest;
    my $bin_dir = NDN_ENV->dest . '/perl/bin';
    my $perl = NDN_ENV->perl;

    return (
        sub {
            return if $self->args->{rebuild};
            print "Checking for cpanm...\n";
            return unless -f "$bin_dir/cpanm";
            print "cpanm already built.\n";
            return 'done';
        },
        "wget --no-check-certificate -O - http://cpanmin.us | $perl - App::cpanminus",
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

