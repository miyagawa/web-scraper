use strict;
use Test::Base;

use Web::Scraper;
plan tests => 1 * blocks;

filters {
    selector => 'chomp',
    expected => 'yaml',
};

run {
    my $block = shift;
    my @value;
    my $s = scraper {
        process '//body' , 'text1[]' => scraper {
            split_by $block->selector, 'text2[]' => scraper {
                #print "process\n";
                process 'div.name', 'name' => 'TEXT';
                process '//div', 'cntnt[]' => 'TEXT';
                #process '//div', 'cntnt' => 'TEXT';
                #result 'text';
            };
        };
    };
    my $res=$s->scrape($block->html);
#use YAML;
#open my $out,'>','out.yml';
#print $out Dump($res);
    is_deeply $res, $block->expected, $block->name;
};

__DATA__

===
--- html
<html>
<body>
<div class="foo"></div>
<div class="name">Name1</div>
<div>bar1</div>
<div class="foo"></div>
<div class="name">Name2</div>
<div>bar2</div>
</body>
</html>
--- selector
div.foo
--- expected
text1:
  - text2:
      - cntnt:
          - ''
          - Name1
          - bar1
        name: Name1
      - cntnt:
          - ''
          - Name2
          - bar2
        name: Name2
