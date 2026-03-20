#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DeathByCaptcha::HttpClient;
use DeathByCaptcha::SocketClient;


my ($username, $password, $filename) = @ARGV;

if (!defined $username || !defined $password) {
	die "Usage: perl $0 <username|authtoken> <password|token> [captcha_file]\n";
}

# Put your DeathByCaptcha username & password here:
# if using authtoken authentication $username must be authtoken
# and $password must be the authtoken from user panel
# using authtoken in user panel disables username/password authentication
my $client = DeathByCaptcha::HttpClient->new($username, $password);
# my $client = DeathByCaptcha::SocketClient->new($username, $password);

printf("Your balance is %f US cents\n", $client->getBalance());

if ($filename) {
	printf("Provided captcha: $filename \n");
	# Put your CAPTCHA image file name and desired solving timeout (in seconds) here:
	my $captcha = $client->decode($filename, +DeathByCaptcha::Client::DEFAULT_TIMEOUT);
	if (defined $captcha) {
	    print "CAPTCHA " . $captcha->{"captcha"} . " solved: " . $captcha->{"text"} . "\n";

	    # Report if the CAPTCHA was solved incorrectly.
	    # Make sure it was in fact solved incorrect, do not just report every
	    # CAPTCHA, or you'll get banned as abuser.
	    #$client->report($captcha->{"captcha"});
	}
} else {
	printf("No captcha provided \n");
}

