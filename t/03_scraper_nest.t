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
        process $block->selector,
            'friends[]' => scraper {
                process 'a', href => '@href',
            };
        result 'friends';
    };

    my $res = $s->scrape($block->html);
    is_deeply $res, $block->expected, $block->name;
};

__DATA__

===
--- html
<ul>
<li class="foo"><a href="foo1">bar1</a></li>
<li class="bar"><a href="foo2">bar2</a></li>
<li class="foo"><a href="foo3">bar3</a></li>
</ul>
--- selector
li.foo
--- expected
- href: foo1
- href: foo3
