use strict;
use Test::Base;

use Data::Dumper;
use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    arg      => 'chomp',
    callback => 'chomp',
    expected => 'yaml',
};

run {
    my $block = shift;
    my $s = scraper {
        process $block->selector, $block->arg, sub {
            my $node = shift;
            my %hash = eval $block->callback;
            fail $@ if $@;
            return %hash;
        }
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
--- arg
sites{}
--- callback
($node->as_text, $node->attr('href'))
--- expected
sites:
  foo : foo.html
  bar : bar.html
