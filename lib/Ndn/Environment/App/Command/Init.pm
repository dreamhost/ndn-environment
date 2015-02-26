package Ndn::Environment::App::Command::Init;

use strict;
use warnings;

use Ndn::Environment::App -command;

sub usage_desc { "$0 init [PATH]\n\nPATH defaults to '.'" }

my %FILES = (
    source          => {},
    'env_config.pm' => <<'    EOT',
{
    # Version of perl to download and use
    perl_version => undef, # Example: 5.16.3

    # Add 'modperl' to this if you want it:
    package_builds => [ qw/perl cpanm envpan modules/ ],

    # Packaging details:
    package_type        => 'deb',
    package_name        => 'ndn-environment',
    package_maintainer  => 'someone FABULOUS!',
    package_description => 'ndn-environment by someone FABULOUS!',
    package_depends     => q{},
    package_version     => sub { time() }, # Set version to build timestamp

    modperl_apxs   => '/usr/bin/apxs2',
    modperl_rename => 'mod_perl_custom_BUILD.so',

    # List of modules to build into the environment
    modules => [
        # Add your list of modules here:
        'Test::More',
    ],
}
    EOT
);

sub execute {
    my ($self, $opt, $args) = @_;

    my ($root) = @$args;
    $root ||= '.';

    if ( !-e $root ) {
        mkdir($root) || die "Could not create '$root': $!";
    }

    for my $path ( keys %FILES ) {
        my $content = $FILES{$path};
        $self->build_path(
            join( '/', $root, $path ),
            $content,
        );
    }

    print "New Ndn-Environment directory initialized: $root\n";
}

sub build_path {
    my $self = shift;
    my ( $path, $content ) = @_;

    if ( ref $content ) {
        mkdir $path;
        for my $subpath ( keys %$content ) {
            $self->build_path(
                join( '/', $path, $subpath ),
                $content->{$subpath},
            );
        }
    }
    else {
        open( my $file, '>', $path ) || die "Count not create '$path': $!";
        print $file $content;
        close($file);
    }
}

1;

__END__

=head1 NAME

Ndn::Environment::App::Command::Init - Initialize a new environment


=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

