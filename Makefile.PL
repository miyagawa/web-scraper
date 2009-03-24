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
if (eval { require HTML::TreeBuilder::LibXML }) {
    setup_libxml_tests();
}

use_test_base;
auto_include;
author_tests "xt";
WriteAll;

sub setup_libxml_tests {
    my @tests = glob "t/*.t";
    for my $test (@tests) {
        (my $new = $test) =~ s!^t/!t/libxml-!;
        open my $in, "<", $test;
        open my $out, ">", $new;

        while (<$in>) {
            print $out $_;
            if (/^use Web::Scraper/) {
                print $out "use HTML::TreeBuilder::LibXML;\n";
            }
        }
    }
}
