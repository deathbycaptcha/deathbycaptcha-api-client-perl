use strict;
use warnings;

use lib '.';

use File::Temp qw(tempfile);
use Test::More;

use DeathByCaptcha::Client;

{
    package Local::ClientMock;
    use parent 'DeathByCaptcha::Client';

    sub new {
        my ($class, %args) = @_;
        return bless \%args, $class;
    }

    sub upload {
        my ($self, $fn) = @_;
        return $self->{upload_result};
    }

    sub getCaptcha {
        my ($self, $id) = @_;
        if (ref $self->{captcha_queue} eq 'ARRAY' && @{$self->{captcha_queue}}) {
            return shift @{$self->{captcha_queue}};
        }
        return $self->{captcha_result};
    }

    sub getUser {
        my ($self) = @_;
        return $self->{user_result};
    }
}

# loadImage: validation + binary-safe read
like(
    exception_text(sub { DeathByCaptcha::Client::loadImage(undef) }),
    qr/Image file path is required/,
    'loadImage croaks when no file path is provided',
);

my ($fh, $path) = tempfile();
binmode $fh;
print {$fh} "A\x00B\xFF";
close $fh;

is(
    DeathByCaptcha::Client::loadImage($path),
    "A\x00B\xFF",
    'loadImage reads full file in raw mode',
);

# get_poll_interval sequence and fallback
my @expected = (1, 1, 2, 3, 2, 2, 3, 2, 2, 3, 3);
my $idx = 0;
for my $want (@expected) {
    my ($got, $new_idx) = DeathByCaptcha::Client::get_poll_interval($idx);
    is($got, $want, "poll interval at index $idx is $want");
    is($new_idx, $idx + 1, 'poll interval increments index');
    $idx = $new_idx;
}

# getBalance / getText
my $client = Local::ClientMock->new(user_result => { user => 123, balance => 42.5 });
is($client->getBalance(), 42.5, 'getBalance returns user balance');

$client = Local::ClientMock->new(user_result => { user => 0, balance => 42.5 });
ok(!defined $client->getBalance(), 'getBalance returns undef when user id is invalid');

$client = Local::ClientMock->new(captcha_result => { captcha => 11, text => 'abc' });
is($client->getText(11), 'abc', 'getText returns solved text');

$client = Local::ClientMock->new(captcha_result => { captcha => 11, text => '' });
ok(!defined $client->getText(11), 'getText returns undef for empty text');

# decode: success path without waiting
$client = Local::ClientMock->new(
    upload_result => { captcha => 10, text => 'ready', is_correct => 1 },
);
my $decoded = $client->decode('ignored.jpg', 1);
is($decoded->{text}, 'ready', 'decode returns solved captcha when already solved and correct');

# decode: solved but incorrect
$client = Local::ClientMock->new(
    upload_result => { captcha => 10, text => 'ready', is_correct => 0 },
);
ok(!defined $client->decode('ignored.jpg', 1), 'decode returns undef when solved but incorrect');

# decode: upload failure
$client = Local::ClientMock->new(upload_result => undef);
ok(!defined $client->decode('ignored.jpg', 1), 'decode returns undef when upload fails');

done_testing;

sub exception_text {
    my ($code) = @_;
    my $err;
    eval { $code->(); 1 } or $err = $@;
    return $err || '';
}
