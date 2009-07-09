package Web::Scraper::LibXML;
use strict;
use base qw( Web::Scraper );

use HTML::TreeBuilder::LibXML;

sub build_tree {
    my($self, $html) = @_;

    my $t = HTML::TreeBuilder::LibXML->new;
    $t->parse($html);
    $t->eof;
    $t;
}

1;

__END__

=head1 NAME

Web::Scraper::LibXML - Drop-in replacement for Web::Scraper to use LibXML

=head1 SYNOPSIS

  use Web::Scraper::LibXML;

  # same as Web::Scraper
  my $scraper = scraper { ... };

=head1 DESCRIPTION

Web::Scraper::LibXML is a drop-in replacement for Web::Scraper to use
the fast libxml-based HTML tree builder, HTML::TreeBuilder::LibXML.

This is almost identical to HTML::TreeBuilder::LibXML's
I<replace_original> installer, like:

  use HTML::TreeBuilder::LibXML;
  HTML::TreeBuilder::LibXML->replace_original();
  
  use Web::Scraper;
  my $scraper = scraper { ... };
  # this code uses LibXML parser

which overrides HTML::TreeBuilder::XPath's new() constructor so that
L<ALL> of your code using HTML::TreeBuilder::XPath is switched to the
libxml based parser.

This module, instead, gives you more control over which TreeBuilder to
use, depending on the site etc.

=head1 SEE ALSO

L<Web::Scraper> L<HTML::TreeBuilder::LibXML>

=cut
