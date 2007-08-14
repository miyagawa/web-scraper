use strict;
use Test::Base;

use Web::Scraper;
plan skip_all => "LEAK_TEST is not defined"
    unless $ENV{LEAK_TEST} || $ENV{TEST_ALL};

plan tests => 1;

filters {
    selector => 'chomp',
    expected => 'chomp',
};

use Devel::Leak;

run {
    my $block = shift;

    for (1..10) {
        my $s = scraper {
            process $block->selector, text => 'TEXT';
            result 'text';
        };
        my $text = $s->scrape($block->html);
        diag `ps uxww | grep "08-leak.t" | grep -v grep | grep -v harness`;
    }
};

ok 1;

__DATA__

===
--- html
<div id="foo">bar</div>
--- selector
div#foo
--- expected
bar
