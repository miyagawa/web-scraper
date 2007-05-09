#!/usr/bin/perl
use strict;
use warnings;
use lib "lib";
use URI;
use Web::Scraper;

my $nick = shift || "miyagawa";
my $uri  = URI->new("http://twitter.com/$nick");

my $twitter = scraper {
    process 'a[rel="contact"]',
        'friends[]' => scraper {
            process 'a',   url => '@href', name => '@title';
            process 'img', src => '@src';
        };
    result 'friends';
};

my $friends = $twitter->scrape($uri);

use YAML;
warn Dump $friends;

