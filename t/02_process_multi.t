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
    my $s = scraper {
        process $block->selector, 'text[]' => 'TEXT';
        result 'text';
    };
    my $texts = $s->($block->html);
    is_deeply $texts, $block->expected, $block->name;
};

__DATA__

===
--- html
<ul>
<li class="foo">bar1</li>
<li class="bar">bar2</li>
<li class="foo">bar3</li>
</ul>
--- selector
li.foo
--- expected
- bar1
- bar3
