package Ndn::Environment::EnvPAN;
use strict;
use warnings;

use Config;
use base 'Exporter';
use Carp qw/croak confess/;
use File::Temp qw/tempfile/;
use List::Util qw/first/;

use Ndn::Environment;

our @EXPORT_OK = qw(
    install_module
    inject_module
);

my %NESTING;

sub _module_url {
    my ($source) = @_;

    my $perl = NDN_ENV->perl;

    my $code = <<"    EOT";
        require MetaCPAN::API;
        my \$c = MetaCPAN::API->new;
        my \$dist = \$c->module("$source")->{distribution} || die "No dist found";
        my \$rel = \$c->release( distribution => \$dist )  || die "No release found";
        print \$rel->{download_url} . "\\n";
    EOT

    chomp( my $url = `$perl -e '$code'` );

    return $url;
}

sub inject_module {
    my @modules = @_;

    my $perl   = NDN_ENV->perl;
    my $inject = 'local/bin/orepan2-inject';
    my $index  = 'local/bin/orepan2-indexer';

    my $cwd = NDN_ENV->cwd;
    local %ENV = %ENV;
    my $plib = "$cwd/local/lib/perl5";
    opendir(my $dh, $plib) || die "Could not open '$plib'";
    my $alib = first { -e "$plib/$_/Mouse.pm" || -e "$plib/$_/Moose.pm" } readdir($dh);
    close($dh);
    local $ENV{PERL5LIB} = "$plib:$plib/$alib";

    for my $mod (@modules) {
        my $src = $mod =~ '/' ? $mod : _module_url($mod);

        print "Injecting $mod ($src)...\n";
        my $command = "$perl $inject --no-generate-index $src envpan";
        system("$command") && die "PERL5LIB=\"$ENV{PERL5LIB}\" $command";
    }

    print "Rebuilding index...\n";
    system("$perl $index envpan >/dev/null 2>&1");
}

sub install_module {
    my ( $module, %params ) = @_;

    $NESTING{$module}++;
    die "Infinite nest?" if $NESTING{$module} > 3;

    confess "You must specify a 'from' param of either 'cpan' or 'mirror'"
        unless $params{from};

    #<<< no-tidy
    my @cpanm_args = $params{from} eq 'cpan' ? () : (
        "--mirror-only",
        "--mirror=file://" . NDN_ENV->cwd . "/envpan",
    );
    #>>>

    push @cpanm_args => "-l '$params{local_lib}'"
        if $params{local_lib};

    local %ENV = ( %ENV, %{$params{env}})
        if $params{env};

    my $perl  = NDN_ENV->perl;
    my $cpanm = NDN_ENV->cpanm;

    my $command = join " " => (
        $perl,
        $cpanm,
        $params{cpanm_args} ? $params{cpanm_args} : (),
        @cpanm_args,
        $module,
    );

    print "Installing Module: $module ($command)\n";

    my ($th, $tf) = tempfile;
    close($th);

    system( "$command 2>&1 | tee $tf" ) && die "tee command failed: $!";

    my (@fetch, @inst, $fail);
    open( $th, '<', $tf ) || die "Could not open '$tf': $!";
    while (my $line = <$th>) {
        $fail ||= $line =~ m/Bailing out the installation/;

        if( $line =~ m{Installing \S+ failed\. See (\S+) for details}) {
            die "Error, check $1\n";
        }

        if( my @modules = ($line =~ m/Finding (\S+) \([^\)]*\) on mirror/g)) {
            push @fetch => @modules;
            next;
        }

        if ( my @modules = ($line =~ m/Module '(\S+)' is not installed/g)) {
            push @inst => $1;
        }

        if ($line =~ m/Installed version \([^\)]*\) of (\S+) is not in range/) {
            push @inst => $1;
        }
    }

    if (@inst || @fetch || $fail) {
        die "cpanm failed" unless $params{auto_inject};

        if (@inst || @fetch) {
            my %seen;
            my @need = grep { $_ && !$seen{$_}++ } @inst, @fetch;
            print "Found deps: " . join( ", ", @need ) . "\n";
            inject_module(@fetch);
            install_module( $_, %params ) for grep { $_ ne $module } @need;
            install_module( $module, %params );
        }
        else {
            die "Error installing $module";
        }
    }

    $NESTING{$module}--;
}

1;

__END__

=head1 NAME

Ndn::Environment::EnvPAN - Interface to the envpan Darkpan

=head1 SYNOPSYS

	use Ndn::Environment::EnvPAN qw/inject_module install_module/;

	inject_module( 'Foo::Bar', 'Baz::Bat' );

	install_module  'Foo::Bar' => (auto_inject => 1);

=head1 API

=over 4

=item inject_module( @MODULES )

Inject 1 or more modules into the darkpan. Modules will be downloaded from cpan
and then injected. After the injection the module index will be rebuilt, this
could take a long time if there are a lot of modules.

=item install_module($MODULE)

=item install_module($MODULE, %PARAMS)

=item install_module $MODULE => (%PARAMS)

Install a module.

=back

=head2 INSTALL PARAMS

=over 4

=item from => 'cpan'

=item from => 'mirror'

Required, specify to fetch modules from either cpan or the envpan mirror.

=item local_lib => $PATH

Optional, will install modules to the specified local_lib directory

=item env => \%CUSTOM_ENV

Will build the modules with the specified %ENV overrides.

=item cpanm_args => "..."

Arguments to pass into cpanm

=back

=head1 COPYRIGHT

Copyright (C) 2013 New Dream Network LLC

Ndn-Environment is free software; FreeBSD License

NDN-Environment is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the license for more details.

