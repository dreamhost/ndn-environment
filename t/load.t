#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

require_ok 'Ndn::Environment';
require_ok 'Ndn::Environment::Util';
require_ok 'Ndn::Environment::EnvPAN';

require_ok 'Ndn::Environment::App';
require_ok 'Ndn::Environment::App::Command::AddModule';
require_ok 'Ndn::Environment::App::Command::Build';
require_ok 'Ndn::Environment::App::Command::Init';

require_ok 'Ndn::Environment::Builder';
require_ok 'Ndn::Environment::Builder::Cpanm';
require_ok 'Ndn::Environment::Builder::Modules';
require_ok 'Ndn::Environment::Builder::Package';
require_ok 'Ndn::Environment::Builder::Perl';

done_testing;
