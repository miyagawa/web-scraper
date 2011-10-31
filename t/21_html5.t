use strict;
use Test::Base;

use utf8;
use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    expected => [ 'chomp', 'newline' ],
    html     => 'newline',
};

sub newline {
    s/\\n\n/\n/g;
}

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

=== header
--- html
<header>hello</header>
--- selector
header
--- expected
hello

=== section
--- html
<header>hello</header>
--- selector
header
--- expected
hello
