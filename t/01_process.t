use strict;
use Test::Base;

use Web::Scraper;
plan tests => 2 * blocks;

filters {
    selector => 'chomp',
    expected => 'chomp',
};

run {
    my $block = shift;
    for (0..1) {
        my $s = scraper {
            process $block->selector, text => 'TEXT';
            result 'text';
        };
        $s->use_libxml($_);
        my $text = $s->scrape($block->html);
        is $text, $block->expected, $block->name;
    }
};

__DATA__

===
--- html
<div id="foo">bar</div>
--- selector
div#foo
--- expected
bar

===
--- html
<span><a href="foo">baz</a></span>
--- selector
span a[href]
--- expected
baz

===
--- html
<span><a href="foo">baz</a></span>
--- selector
//span/a
--- expected
baz
