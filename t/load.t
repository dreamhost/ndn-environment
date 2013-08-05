#!/usr/bin/perl
use strict;
use warnings;

use Test::More;

require_ok 'Ndn::Environment';
require_ok 'Ndn::Environment::Util';
require_ok 'Ndn::Environment::EnvPAN';

require_ok 'Ndn::Environment::CLI';
require_ok 'Ndn::Environment::Command';
require_ok 'Ndn::Environment::Command::AddModule';
require_ok 'Ndn::Environment::Command::Build';
require_ok 'Ndn::Environment::Command::Help';
require_ok 'Ndn::Environment::Command::Init';
require_ok 'Ndn::Environment::Command::Purge';

require_ok 'Ndn::Environment::Builder';
require_ok 'Ndn::Environment::Builder::Cpanm';
require_ok 'Ndn::Environment::Builder::EnvPAN';
require_ok 'Ndn::Environment::Builder::ModPSGI';
require_ok 'Ndn::Environment::Builder::Modules';
require_ok 'Ndn::Environment::Builder::Package';
require_ok 'Ndn::Environment::Builder::Perl';

done_testing;
