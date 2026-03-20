use strict;
use warnings;

use lib '.';

use Test::More;

use_ok('DeathByCaptcha::Client');
use_ok('DeathByCaptcha::Exception');
use_ok('DeathByCaptcha::HttpClient');
use_ok('DeathByCaptcha::SocketClient');

done_testing;
