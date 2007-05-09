#!/usr/bin/perl
use strict;
use warnings;

use lib "lib";
use Web::Scraper;
use URI;
use YAML;

# extract HD trailers from Dave's trailer page
my $uri  = URI->new("http://www.drfoster.f2s.com/");

my $s = scraper {
    process "td>ul>li", "trailers[]" => scraper {
        process_first "li>b", title => "TEXT";
        process_first "ul>li>a[href]", url => '@href';
        process "ul>li>ul>li>a", "movies[]" => sub {
            my $elem = shift;
            return {
                text => $elem->as_text,
                href => $elem->attr('href'),
            };
        };
    };
    result "trailers";
};

warn Dump $s->scrape($uri);
