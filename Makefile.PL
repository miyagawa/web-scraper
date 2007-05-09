use inc::Module::Install;
name 'Web-Scraper';
all_from 'lib/Web/Scraper.pm';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
