use inc::Module::Install;
name 'Web-Scraper';
all_from 'lib/Web/Scraper.pm';

requires 'Scalar::Util';
requires 'HTML::TreeBuilder::XPath';
requires 'HTML::Selector::XPath';
requires 'LWP::UserAgent';
requires 'HTTP::Response::Encoding';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
