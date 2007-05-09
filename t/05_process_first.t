use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    expected => 'yaml',
};

run {
    my $block = shift;
    my @value;
    my $s = scraper {
        process_first $block->selector, sub {
            my $node = shift;
            push @value, eval $block->callback;
            fail $@ if $@;
        };
    };
    $s->scrape($block->html);
    is_deeply \@value, $block->expected, $block->name;
};

__DATA__

===
--- html
<ul>
<li class="foo"><span title="baz">bar1</span></li>
<li class="foo"><span title="bad">bar3</span></li>
</ul>
--- selector
li.foo span
--- callback
$node->attr('title')
--- expected
- baz
