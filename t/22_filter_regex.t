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
    my $want = $s->scrape('<a>foo=123</a><a>bar=456</a>');
    is_deeply $want, $block->expected, $block->name;
};

__DATA__

=== unnamed
--- want
[ TEXT => qr/(\d+)/ ]
--- expected
- 123
- 456

=== named
--- want
[ TEXT => qr/^(?<name>\w+)=(?<value>\d+)$/ ]
--- expected
- name: foo
  value: 123
- name: bar
  value: 456

=== boolean
--- want
[ TEXT => qr/BAR/i ]
--- expected
-
- 1

=== stack
--- want
[ TEXT => qr/(\w+)/ => sub { ucfirst } ]
--- expected
- Foo
- Bar
