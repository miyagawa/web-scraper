use strict;
use Test::Base;

use utf8;
use Web::Scraper;

plan skip_all => "Please upgrade HTML::TreeBuilder::XPath and HTML::TreeBuilder::LibXML modules for comment nodes supporting"
    unless
    eval "use HTML::TreeBuilder::XPath 0.14; 1" &&
    eval "use HTML::TreeBuilder::LibXML 0.13; 1";

plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    expected => [ 'chomp', 'newline' ],
    html     => 'newline',
};

sub newline {
    s/\\n\n/\n/g;
}

# For turning off of "Wide character warnings if test failed"
my $builder = Test::More->builder;
binmode $builder->output,         ":utf8";
binmode $builder->failure_output, ":utf8";
binmode $builder->todo_output,    ":utf8";

run {
    my $block = shift;
    my $s = scraper {
        process $block->selector, want => 'TEXT';
        result 'want';
    };
    my $want = $s->scrape($block->html);
    is $want, $block->expected, $block->name;
};

__DATA__

=== comment in p
--- html
<p>This is a paragraph <!-- This is the comment --> bla bla bla</p>
--- selector
//p/comment()
--- expected
 This is the comment 

=== non-ascii comment
--- html
<p id="foo"><!-- テスト -->Bla bla bla</p>
--- selector
//p/comment()
--- expected
 テスト 
