use strict;
use warnings;
use URI;
use LWP::UserAgent;
use Web::Scraper;
use Test::More;

plan skip_all => "LIVE_TEST not enabled"
    unless $ENV{LIVE_TEST} || $ENV{TEST_ALL};

plan tests => 1;

my $ua = LWP::UserAgent->new;
{
    my $res = $ua->get("http://www.yahoo.co.jp/");
    my $result = scraper {
        process 'title', title => 'TEXT';
    }->scrape($res);
    is $result->{title}, 'Yahoo! JAPAN';
}


