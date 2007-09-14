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
        process $block->selector, want => $block->want;
        result 'want';
    };
    my $want = $s->scrape($block->html, $block->url);
    is $want, $block->expected, $block->name;
};

__DATA__

=== a@href
--- url: http://example.com/
--- html
<a id="foo" href="foo.html">bar</a>
--- selector
a#foo
--- want: @href
--- expected
http://example.com/foo.html

=== a@href absolute
--- url: http://example.com/
--- html
<a id="foo" href="http://example.org/foo.html">bar</a>
--- selector
a#foo
--- want: @href
--- expected
http://example.org/foo.html

=== img@src
--- url: http://example.com/bar/baz
--- html
<img src="/img/foo.jpg" />
--- selector
img
--- want: @src
--- expected
http://example.com/img/foo.jpg
