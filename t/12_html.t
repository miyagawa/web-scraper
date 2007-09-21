use strict;
use Test::Base;

use utf8;
use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    expected => 'chomp',
};

run {
    my $block = shift;
    my $s = scraper {
        process $block->selector, want => 'HTML';
        result 'want';
    };
    my $want = $s->scrape($block->html);
    is $want, $block->expected, $block->name;
};

__DATA__

=== script
--- html
<script>function foo() {
  return bar;
}
</script>
--- selector
script
--- expected
function foo() {
  return bar;
}

=== a
--- html
<a id="foo"><span>foo</span> bar</a>
--- selector
a
--- expected
<span>foo</span> bar

=== div
--- html
<div id="foo">
<p>foo
bar</p>
<p>bar</p>
</div>
--- selector
#foo
--- expected
<p>foo bar</p><p>bar</p>

=== non-ascii
--- html
<p id="foo">テスト</p>
--- selector
#foo
--- expected
テスト
