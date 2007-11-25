use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    want     => 'chomp',
    expected => 'chomp',
};

run {
    my $block = shift;
    my $s = scraper {
        process $block->selector, want => $block->want;
        result 'want';
    };
    my $want = $s->scrape($block->html);
    is $want, $block->expected, $block->name;
};

__DATA__

=== TEXT
--- html
<p><s>foo</s> bar</p>
--- selector
//p/node()[2]
--- want
TEXT
--- expected
 bar

=== TEXT
--- html
<p><s>foo</s> bar</p>
--- selector
//p/node()[2]
--- want
TEXT
--- expected
 bar

=== TEXT
--- html
<p><s>foo</s> bar &amp; baz</p>
--- selector
//p/node()[2]
--- want
TEXT
--- expected
 bar & baz

=== RAW HTML
--- SKIP
--- html
<p><s>foo</s> bar &amp; baz</p>
--- selector
//p/node()[2]
--- want
RAW
--- expected
 bar &amp; baz
