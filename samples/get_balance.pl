#!/usr/bin/env perl

use strict;
use warnings;

use FindBin qw($Bin);
use lib "$Bin/..";

use DeathByCaptcha::HttpClient;
use DeathByCaptcha::SocketClient;


my ($username, $password, $clienttype) = @ARGV;
my $client;

if (!defined $username || !defined $password) {
	die "Usage: perl $0 <username|authtoken> <password|token> [HTTP|SOCKET]\n";
}

$clienttype = uc($clienttype // 'SOCKET');

if ($clienttype eq "HTTP"){
	printf("http client\n");
	$client = DeathByCaptcha::HttpClient->new($username, $password);
} else {
	printf("socket client\n");
	$client = DeathByCaptcha::SocketClient->new($username, $password);	
}

printf("Your balance is %f US cents\n", $client->getBalance());

