use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    expected => 'chomp',
    want => 'eval',
};

run {
    my $block = shift;
    my $s = scraper {
        process 'a', want => $block->want;
        result 'want';
    };
    my $want = $s->scrape('<a>foo</a>');
    my $expected = $block->expected eq 'undef' ? undef : $block->expected;

    is $want, $expected, $block->name;
};

BEGIN {
    package Web::Scraper::Filter::foo;
    use base qw( Web::Scraper::Filter );
    sub filter { tr/a-z/b-za/ }

    package Web::Scraper::Filter::bar;
    use base qw( Web::Scraper::Filter );
    sub filter { $_[1] . 'bar' }
}

package main;

__DATA__

=== tr
--- want
['TEXT', 'foo']
--- expected
gpp

=== shift + return
--- want
['TEXT', 'bar']
--- expected
foobar

=== inline callback
--- want
['TEXT', sub { return "baz" } ]
--- expected
baz

=== inline callback + s///
--- want
['TEXT', sub { s/foo/bax/ } ]
--- expected
bax

=== stack
--- want
['TEXT', 'bar', 'foo' ]
--- expected
gppcbs

=== stack
--- want
['TEXT', 'bar', sub { s/foo/bar/ } ]
--- expected
barbar

=== no match
--- want
['TEXT', sub { s/xxx/yyy/g }]
--- expected
foo

=== undef
--- want
['TEXT', sub { return }]
--- expected
undef

=== number
--- want
['TEXT', sub { return 3 }]
--- expected
3

=== object
--- want
['TEXT', Web::Scraper::Filter::foo->new]
--- expected
gpp
