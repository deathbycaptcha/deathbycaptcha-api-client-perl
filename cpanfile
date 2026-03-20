requires 'LWP::UserAgent';
requires 'LWP::Protocol::https';
requires 'HTTP::Request::Common';
requires 'HTTP::Status';
requires 'JSON';
requires 'IO::Socket';
requires 'MIME::Base64';

on test => sub {
    requires 'Test::More', '0.98';
};
