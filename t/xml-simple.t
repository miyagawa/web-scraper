use strict;
use Test::Base;
use Web::Scraper::LibXML;

filters { expected => [ 'lines', 'chomp' ] };

plan tests => 1 * blocks;
run {
    my $block = shift;
    my $s = scraper {
        process $block->selector, "value[]", $block->get;
    };
    my $r = $s->scrape($block->input);
    is_deeply $r->{value}, [ $block->expected ];
};

__END__

===
--- input
<?xml version="1.0" encoding="utf-8"?>
<foo>bar</foo>
--- selector: foo
--- get: TEXT
--- expected
bar

===
--- input
<?xml version="1.0" encoding="utf-8"?>
<foo>
  <bar>baz</bar>
  <bar>bax</bar>
</foo>
--- selector: foo>bar
--- get: TEXT
--- expected
baz
bax

===
--- input
<?xml version="1.0" encoding="utf-8"?>
<foo>
  <bar attr="test bar" />
  <bar attr="Hello &amp; World" />
</foo>
--- selector: bar
--- get: @attr
--- expected
test bar
Hello & World




