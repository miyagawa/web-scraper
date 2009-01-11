use inc::Module::Install;
name 'Web-Scraper';
all_from 'lib/Web/Scraper.pm';

requires 'Scalar::Util';
requires 'HTML::TreeBuilder::XPath', 0.08;
requires 'HTML::TreeBuilder', 3.23;
requires 'XML::XPathEngine', 0.08;
requires 'HTML::Selector::XPath', 0.03;
requires 'LWP::UserAgent';
requires 'HTTP::Response::Encoding';
requires 'HTML::Entities';
requires 'HTML::Tagset';
requires 'UNIVERSAL::require';
requires 'URI';
requires 'YAML';

build_requires 'Test::More';
install_script 'bin/scraper';

use_test_base;
auto_include;
WriteAll;

