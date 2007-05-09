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
        process $block->selector, text => 'TEXT';
        result 'text';
    };
    my $text = $s->($block->html);
    is $text, $block->expected, $block->name;
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
