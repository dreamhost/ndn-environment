use strict;
use warnings;

use Test::More;

use Ndn::Environment::EnvPAN;

like
    Ndn::Environment::EnvPAN::_module_url('Moose') => qr!https?://!,
    'looks like a url!';

done_testing;
