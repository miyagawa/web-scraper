use strict;
use warnings;
use URI;
use LWP::UserAgent;
use Web::Scraper;
use Test::More;

plan skip_all => "LIVE_TEST not enabled"
    unless $ENV{LIVE_TEST} || $ENV{TEST_ALL};

plan tests => 2;

my $ua = LWP::UserAgent->new;
{
    my $res = $ua->get("http://www.yahoo.co.jp/");
    my $result = scraper {
        process 'title', title => 'TEXT';
    }->scrape($res);
    is $result->{title}, 'Yahoo! JAPAN';
}

{
    my $res = $ua->get("http://b.hatena.ne.jp/");
    my $result = scraper {
        process 'img.csschanger', image => '@src';
    }->scrape($res);
    is $result->{image}, 'http://b.hatena.ne.jp/images/logo1.gif', 'Absolute URI';
}



