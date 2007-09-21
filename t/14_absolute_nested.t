use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    expected => 'chomp',
};

run {
    my $block = shift;
    my $s = scraper {
        process $block->selector, want => scraper {
            process "img", image => '@src';
            result "image";
        };
        result 'want';
    };
    my $want = $s->scrape($block->html, $block->url);
    is $want, $block->expected, $block->name;
};

__DATA__

===
--- url: http://example.com/
--- html
<a id="foo" href="foo.html"><img src="foo.jpg" /></a>
--- selector
a#foo
--- expected
http://example.com/foo.jpg
