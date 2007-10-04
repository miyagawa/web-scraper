use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    expected => 'yaml',
    want => 'eval',
};

run {
    my $block = shift;
    my $s = scraper {
        process 'a', 'want[]' => $block->want;
        result 'want';
    };
    my $want = $s->scrape('<a>foo</a><a>bar</a>');
    is_deeply $want, $block->expected, $block->name;
};

__DATA__

=== tr
--- want
['TEXT', sub { tr/a-z/b-za/ }]
--- expected
- gpp
- cbs
