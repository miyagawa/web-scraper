use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    args     => 'yaml',
    expected => 'yaml',
};

run {
    my $block = shift;
    my $s = scraper {
        process $block->selector, @{ $block->args };
    };
    my $data = $s->scrape($block->html);
    is_deeply $data, $block->expected, $block->name;
};

__DATA__

===
--- html
<ul>
<li><a href="foo.html">foo</a></li>
<li><a href="bar.html">bar</a></li>
</ul>
--- selector
ul>li>a
--- args
- sites[]
- link: '@href'
  name: TEXT
--- expected
sites:
  - link: foo.html
    name: foo
  - link: bar.html
    name: bar
