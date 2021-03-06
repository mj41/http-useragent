use v6;

use HTTP::UserAgent;
use Test;

plan 2;

throws_like 'use HTTP::UserAgent; my $ssl = HTTP::UserAgent.new; $ssl.get("https://filip.sergot.pl")', X::HTTP::Response, message => "Response error: '403 Forbidden'";

my $url = 'https://github.com/';

my $ssl = HTTP::UserAgent.new;
my $get = ~$ssl.get($url);

is $get.substr($get.chars - 10), "</html>\n\r\n", 'get 1/1';
# it should definitely have more/better tests
