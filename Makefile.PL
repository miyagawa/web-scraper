use inc::Module::Install;
name 'Web-Scraper';
all_from 'lib/Web/Scraper.pm';

requires 'Scalar::Util';
requires 'HTML::TreeBuilder::XPath', 0.08;
requires 'XML::XPathEngine', 0.08;
requires 'HTML::Selector::XPath';
requires 'LWP::UserAgent';
requires 'HTTP::Response::Encoding';
requires 'HTML::Tagset';
requires 'URI';
requires 'YAML';

build_requires 'Test::More';
install_script 'bin/scraper';

use_test_base;
auto_include;
WriteAll;
