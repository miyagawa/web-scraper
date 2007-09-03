#!/usr/bin/perl
# Extract tags from web pages that have rel-tag microformat
use strict;
use warnings;
use URI;
use URI::Escape;
use Web::Scraper;
use YAML;

my $uri = shift or die "Usage: rel-tag.pl URL\n";

my $scraper = scraper {
    process 'a[rel~="tag"]', 'tags[]' => sub {
        my $uri = URI->new($_->attr('href'));
        my $label = (grep length, split '/', $uri->path)[-1];
           $label =~ s/\+/%20/g;
        uri_unescape($label);
    };
};
warn Dump $scraper->scrape(URI->new($uri));
