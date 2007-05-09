#!/usr/bin/perl
use strict;
use warnings;

# same as http://d.hatena.ne.jp/secondlife/20060922/1158923779

my $keyword = scraper {
    process 'span.title > a:first-child', title => 'content', url => '@href';
    process 'span.furigana', furigana => 'content';
    process 'ul.list-circle > li:first-child > a', category => 'content';
};

my $res = $keyword->(URI->new("http://d.hatena.ne.jp/keyword/%BA%B0%CC%EE%A4%A2%A4%B5%C8%FE"));

use YAML;
warn Dump $res;

__END__
---
category: アイドル
furigana: こんのあさみ
title: 紺野あさ美
url: /keyword/%ba%b0%cc%ee%a4%a2%a4%b5%c8%fe?kid=800
