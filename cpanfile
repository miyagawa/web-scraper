requires 'HTML::Entities';
requires 'HTML::Selector::XPath', '0.03';
requires 'HTML::Tagset';
requires 'HTML::TreeBuilder', '3.23';
requires 'HTML::TreeBuilder::XPath', '0.08';
requires 'LWP', '5.827';
requires 'Scalar::Util';
requires 'UNIVERSAL::require';
requires 'URI';
requires 'XML::XPathEngine', '0.08';
requires 'YAML';
requires 'perl', '5.008001';

on build => sub {
    requires 'ExtUtils::MakeMaker', '6.59';
    requires 'Test::Base';
    requires 'Test::More';
    requires 'Test::Requires';
};
