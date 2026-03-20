use strict;
use warnings;

use lib '.';

use Test::More;

use DeathByCaptcha::Exception;

my $ex = DeathByCaptcha::Exception->new('boom');
isa_ok($ex, 'DeathByCaptcha::Exception');
is("$ex", 'DeathByCaptcha::Exception: boom', 'stringification includes class and message');

my $empty = DeathByCaptcha::Exception->new('');
is("$empty", 'DeathByCaptcha::Exception', 'empty message stringifies as class only');

done_testing;
