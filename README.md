# NAME

Web::Scraper - Web Scraping Toolkit using HTML and CSS Selectors or XPath expressions

# SYNOPSIS

    use URI;
    use Web::Scraper;
    use Encode;

    # First, create your scraper block
    my $authors = scraper {
        # Parse all TDs inside 'table[width="100%]"', store them into
        # an array 'authors'.  We embed other scrapers for each TD.
        process 'table[width="100%"] td', "authors[]" => scraper {
          # And, in each TD,
          # get the URI of "a" element
          process "a", uri => '@href';
          # get text inside "small" element
          process "small", fullname => 'TEXT';
        };
    };

    my $res = $authors->scrape( URI->new("http://search.cpan.org/author/?A") );

    # iterate the array 'authors'
    for my $author (@{$res->{authors}}) {
        # output is like:
        # Andy Adler      http://search.cpan.org/~aadler/
        # Aaron K Dancygier       http://search.cpan.org/~aakd/
        # Aamer Akhter    http://search.cpan.org/~aakhter/
        print Encode::encode("utf8", "$author->{fullname}\t$author->{uri}\n");
    }

The structure would resemble this (visually)
  {
    authors => \[
      { fullname => $fullname, link => $uri },
      { fullname => $fullname, link => $uri },
    \]
  }

# DESCRIPTION

Web::Scraper is a web scraper toolkit, inspired by Ruby's equivalent
Scrapi. It provides a DSL-ish interface for traversing HTML documents and
returning a neatly arranged Perl data structure.

The _scraper_ and _process_ blocks provide a method to define what segments
of a document to extract.  It understands HTML and CSS Selectors as well as
XPath expressions.

# METHODS

## scraper

    $scraper = scraper { ... };

Creates a new Web::Scraper object by wrapping the DSL code that will be fired when _scrape_ method is called.

## scrape

    $res = $scraper->scrape(URI->new($uri));
    $res = $scraper->scrape($html_content);
    $res = $scraper->scrape(\$html_content);
    $res = $scraper->scrape($http_response);
    $res = $scraper->scrape($html_element);

Retrieves the HTML from URI, HTTP::Response, HTML::Tree or text
strings and creates a DOM object, then fires the callback scraper code
to retrieve the data structure.

If you pass URI or HTTP::Response object, Web::Scraper will
automatically guesses the encoding of the content by looking at
Content-Type headers and META tags. Otherwise you need to decode the
HTML to Unicode before passing it to _scrape_ method.

You can optionally pass the base URL when you pass the HTML content as
a string instead of URI or HTTP::Response.

    $res = $scraper->scrape($html_content, "http://example.com/foo");

This way Web::Scraper can resolve the relative links found in the document.

## process

    scraper {
        process "tag.class", key => 'TEXT';
        process '//tag[contains(@foo, "bar")]', key2 => '@attr';
        process '//comment()', 'comments[]' => 'TEXT';
    };

_process_ is the method to find matching elements from HTML with CSS
selector or XPath expression, then extract text or attributes into the
result stash.

If the first argument begins with "//" or "id(" it's treated as an
XPath expression and otherwise CSS selector.

    # <span class="date">2008/12/21</span>
    # date => "2008/12/21"
    process ".date", date => 'TEXT';

    # <div class="body"><a href="http://example.com/">foo</a></div>
    # link => URI->new("http://example.com/")
    process ".body > a", link => '@href';

    # <div class="body"><!-- HTML Comment here --><a href="http://example.com/">foo</a></div>
    # comment => " HTML Comment here "
    #
    # NOTES: A comment nodes are accessed when installed
    # the HTML::TreeBuilder::XPath (version >= 0.14) and/or
    # the HTML::TreeBuilder::LibXML (version >= 0.13)
    process "//div[contains(@class, 'body')]/comment()", comment => 'TEXT';

    # <div class="body"><a href="http://example.com/">foo</a></div>
    # link => URI->new("http://example.com/"), text => "foo"
    process ".body > a", link => '@href', text => 'TEXT';

    # <ul><li>foo</li><li>bar</li></ul>
    # list => [ "foo", "bar" ]
    process "li", "list[]" => "TEXT";

    # <ul><li id="1">foo</li><li id="2">bar</li></ul>
    # list => [ { id => "1", text => "foo" }, { id => "2", text => "bar" } ];
    process "li", "list[]" => { id => '@id', text => "TEXT" };

## process\_first

`process_first` is the same as `process` but stops when the first matching
result is found.

    # <span class="date">2008/12/21</span>
    # <span class="date">2008/12/22</span>
    # date => "2008/12/21"
    process_first ".date", date => 'TEXT';

## result

`result` allows to return not the default value after processing but a single
value specified by a key or a hash reference built from several keys.

    process 'a', 'want[]' => 'TEXT';
    result 'want';

# EXAMPLES

There are many examples in the `eg/` dir packaged in this distribution.
It is recommended to look through these.

# NESTED SCRAPERS

Scrapers can be nested thus allowing to scrape already captured data.

    # <ul>
    # <li class="foo"><a href="foo1">bar1</a></li>
    # <li class="bar"><a href="foo2">bar2</a></li>
    # <li class="foo"><a href="foo3">bar3</a></li>
    # </ul>
    # friends => [ {href => 'foo1'}, {href => 'foo2'} ];
    process 'li', 'friends[]' => scraper {
      process 'a', href => '@href',
    };

# FILTERS

Filters are applied to the result after processing. They can be declared as
anonymous subroutines or as class names.

    process $exp, $key => [ 'TEXT', sub { s/foo/bar/ } ];
    process $exp, $key => [ 'TEXT', 'Something' ];
    process $exp, $key => [ 'TEXT', '+MyApp::Filter::Foo' ];

Filters can be stacked

    process $exp, $key => [ '@href', 'Foo', '+MyApp::Filter::Bar', \&baz ];

More about filters you can find in [Web::Scraper::Filter](https://metacpan.org/pod/Web::Scraper::Filter) documentation.

# XML backends

By default [HTML::TreeBuilder::XPath](https://metacpan.org/pod/HTML::TreeBuilder::XPath) is used, this can be replaces by
a [XML::LibXML](https://metacpan.org/pod/XML::LibXML) backend using [Web::Scraper::LibXML](https://metacpan.org/pod/Web::Scraper::LibXML) module.

    use Web::Scraper::LibXML;

    # same as Web::Scraper
    my $scraper = scraper { ... };

# AUTHOR

Tatsuhiko Miyagawa <miyagawa@bulknews.net>

# LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# SEE ALSO

[http://blog.labnotes.org/category/scrapi/](http://blog.labnotes.org/category/scrapi/)

[HTML::TreeBuilder::XPath](https://metacpan.org/pod/HTML::TreeBuilder::XPath)
