{
    # Version of perl to download and use
    perl_version => '5.16.3',

    package_builds => [qw/perl cpanm envpan modules modperl static/],

    # Packaging details:
    package_type        => 'deb',
    package_name        => "ndn-environment",
    package_maintainer  => "nobody special",
    package_description => "ndn-environment by nobody special.",
    package_depends     => "apache2",

    # Set version to build timestamp
    package_version => sub { time() },

    # List of modules to build into the environment
    modules => [
        # Add your list of modules here:
        'Test::More',
        'Moose',
        'source/Custom.tar.gz',
        'http://path/to/dist.tar.gz',
    ],
}
