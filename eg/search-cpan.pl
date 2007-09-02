#!/usr/bin/perl
# search modules on search.cpan.org and extract name, description and author

use strict;
use warnings;
use URI;
use Web::Scraper;
use YAML;

my $query = shift || "Foo";
my $uri   = URI->new("http://search.cpan.org/search");
$uri->query_form(query => $query, mode => 'all');

my $scraper = scraper {
    process "body#cpansearch>p", 'modules[]' => scraper {
        process "//a[1]", name => 'TEXT', url => '@href';
        process "small", description => 'TEXT';
        process "span.date", date => 'TEXT';
        process q{//a[starts-with(@href, '/~')][2]}, author => 'TEXT';
    };
};

warn Dump $scraper->scrape($uri);
