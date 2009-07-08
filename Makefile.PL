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

unlink glob "t/libxml-*.t";
if (eval q{ use HTML::TreeBuilder::LibXML 0.04; 1 }) {
    setup_libxml_tests();
}

use_test_base;
auto_include;
auto_set_repository;
author_tests "xt";
WriteAll;

sub setup_libxml_tests {
    warn "You have HTML::TreeBuilder::LibXML. Writing tests for it.\n";
    my %skip_tests = map { ("t/$_" => 1) } qw( 12_html.t );
    my @tests = grep !$skip_tests{$_}, glob "t/*.t";
    for my $test (@tests) {
        (my $new = $test) =~ s!^t/!t/libxml-!;
        open my $in, "<", $test;
        open my $out, ">", $new;

        while (<$in>) {
            s/^use Web::Scraper/use Web::Scraper::LibXML/;
            print $out $_;
        }
    }
}
