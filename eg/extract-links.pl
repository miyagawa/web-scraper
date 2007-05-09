#!/usr/bin/perl
use strict;
use warnings;
use URI;
use lib "lib";
use Web::Scraper;

my $uri = shift @ARGV or die "URI needed";

my $scraper = scraper {
    process "a[href]", "urls[]" => '@href';
    result 'urls';
};

my $links = $scraper->scrape(URI->new($uri));
use YAML;
warn Dump $links;

