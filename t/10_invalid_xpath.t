use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
};

run {
    my $block = shift;
    my $ok;
    eval {
        my $s = scraper {
            process $block->selector, sub { $ok = 1 };
        };
        $s->scrape(\"foo");
    };
    like $@, qr/look like/, $@;
};

__DATA__

===
--- selector
a/a

===
--- selector
//

===
--- selector
//[

===
--- selector
//a[

