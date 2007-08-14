use strict;
use warnings;
use utf8;
use URI;
use Web::Scraper;
use Test::More;

plan skip_all => "LIVE_TEST not enabled"
    unless $ENV{LIVE_TEST} || $ENV{TEST_ALL};

plan tests => 1;
require YAML;

my $keyword = scraper {
    process 'span.title > a:first-child', title => 'TEXT', url => '@href';
    process 'span.furigana', furigana => 'TEXT';
    process 'ul.list-circle > li:first-child > a', category => 'TEXT';
};

my $res = $keyword->scrape(URI->new("http://d.hatena.ne.jp/keyword/%BA%B0%CC%EE%A4%A2%A4%B5%C8%FE"));

is_deeply $res, YAML::Load(<<EOF);
---
category: アイドル
furigana: こんのあさみ
title: 紺野あさ美
url: /keyword/%ba%b0%cc%ee%a4%a2%a4%b5%c8%fe
EOF
