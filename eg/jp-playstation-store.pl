#!/usr/bin/perl
use strict;
use Web::Scraper;
use URI;
use YAML;

my $stuff   = URI->new("http://www.jp.playstation.com/store/");
my $scraper = scraper {
    process "#Sinfo p a", 'news[]' => { link => '@href', title => 'TEXT' };
};
my $result = $scraper->scrape($stuff);

print YAML::Dump $result;
