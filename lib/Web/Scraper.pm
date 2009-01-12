package Web::Scraper;
use strict;
use warnings;
use Carp;
use Scalar::Util qw(blessed);
use List::Util qw(first);
use HTML::Entities;
use HTML::Tagset;
use HTML::TreeBuilder::XPath;
use HTML::Selector::XPath;
use UNIVERSAL::require;
use Web::Scraper::Node;

our $VERSION = '0.25';

sub import {
    my $class = shift;
    my $pkg   = caller;

    no strict 'refs';
    *{"$pkg\::scraper"} = \&scraper;
    *{"$pkg\::process"}       = sub { goto &process };
    *{"$pkg\::process_first"} = sub { goto &process_first };
    *{"$pkg\::result"}        = sub { goto &result  };
}

our $UserAgent;

sub __ua {
    require LWP::UserAgent;
    $UserAgent ||= LWP::UserAgent->new(agent => __PACKAGE__ . "/" . $VERSION);
    $UserAgent;
}

sub user_agent {
    my $self = shift;
    $self->{user_agent} = shift if @_;
    $self->{user_agent} || __ua;
}

our $UseLibXML = 0;

sub use_libxml {
    my $self = shift;

    if (blessed $self) {
        $self->{use_libxml} = shift if @_;
        return $self->{use_libxml} || $UseLibXML;
    } else {
        $UseLibXML = shift if @_;
        return $UseLibXML;
    }
}

sub define {
    my($class, $coderef) = @_;
    bless { code => $coderef }, $class;
}

sub scraper(&) {
    my($coderef) = @_;
    bless { code => $coderef }, __PACKAGE__;
}

sub scrape {
    my $self  = shift;
    my($stuff, $current) = @_;
    my($html, $tree);

    if (blessed($stuff) && $stuff->isa('URI')) {
        my $ua  = $self->user_agent;
        my $res = $ua->get($stuff);
        return $self->scrape($res, $stuff->as_string);
    } elsif (blessed($stuff) && $stuff->isa('HTTP::Response')) {
        require Encode;
        require HTTP::Response::Encoding;
        if ($stuff->is_success) {
            my @encoding = (
                $stuff->encoding,
                # could be multiple because HTTP response and META might be different
                ($stuff->header('Content-Type') =~ /charset=([\w\-]+)/g),
                "latin-1",
            );
            my $encoding = first { defined $_ && Encode::find_encoding($_) } @encoding;
            $html = Encode::decode($encoding, $stuff->content);
        } else {
            croak "GET $stuff failed: ", $stuff->status_line;
        }
        $current ||= $stuff->request->uri;
    } elsif (blessed($stuff) &&
             ($stuff->isa('Web::Scraper::Node::HTMLElement') || $stuff->isa('HTML::Element'))) {
        $tree = $stuff->clone;
    } elsif (blessed($stuff) &&
             ($stuff->isa('Web::Scraper::Node::LibXML') || $stuff->isa('XML::LibXML::Element'))) {
        $html = $stuff->toString;
    } elsif (blessed($stuff) && $stuff->isa('Web::Scraper::Node::HTMLElement')) {

    } elsif (ref($stuff) && ref($stuff) eq 'SCALAR') {
        $html = $$stuff;
    } else {
        $html = $stuff;
    }

    if ($self->use_libxml) {
        eval { require XML::LibXML; };
        if ($@) {
            Carp::croak "use_libxml is set but couldn't load XML::LibXML: $@";
        }
    }

    $tree ||= do {
        if ($self->use_libxml) {
            my $parser = XML::LibXML->new();
            $parser->recover(1);
            $parser->recover_silently(1);
            $parser->keep_blanks(0);
            $parser->expand_entities(1);
            my $dom = $parser->parse_html_string($html);
            $dom;
        } else {
            my $t = HTML::TreeBuilder::XPath->new;
            $t->parse($html);
            $t;
        }
    };

    my $stash = {};
    no warnings 'redefine';
    local *process       = create_process(0, $tree, $stash, $current);
    local *process_first = create_process(1, $tree, $stash, $current);

    my $retval;
    local *result = sub {
        $retval++;
        my @keys = @_;

        if (@keys == 1) {
            return $stash->{$keys[0]};
        } elsif (@keys) {
            my %res;
            @res{@keys} = @{$stash}{@keys};
            return \%res;
        } else {
            return $stash;
        }
    };

    my $ret = $self->{code}->($tree);
    unless ($self->use_libxml) {
        $tree->delete;
    }

    # check user specified return value
    return $ret if $retval;

    return $stash;
}

sub create_process {
    my($first, $tree, $stash, $uri) = @_;

    sub {
        my($exp, @attr) = @_;

        my $xpath = $exp =~ m!^(?:/|id\()! ? $exp : HTML::Selector::XPath::selector_to_xpath($exp);
        my @nodes = eval {
            local $SIG{__WARN__} = sub { };
            map Web::Scraper::Node->new($_), $tree->findnodes($xpath);
        };

        if ($@) {
            die "'$xpath' doesn't look like a valid XPath expression: $@";
        }

        @nodes or return;
        @nodes = ($nodes[0]) if $first;

        while (my($key, $val) = splice(@attr, 0, 2)) {
            if (!defined $val) {
                if (ref($key) && ref($key) eq 'CODE') {
                    for my $node (@nodes) {
                        local $_ = $node;
                        $key->($node);
                    }
                } else {
                    die "Don't know what to do with $key => undef";
                }
            } elsif ($key =~ s!\[\]$!!) {
                $stash->{$key} = [ map __get_value($_, $val, $uri), @nodes ];
            } else {
                $stash->{$key} = __get_value($nodes[0], $val, $uri);
            }
        }

        return;
    };
}

sub __get_value {
    my($node, $val, $uri) = @_;

    if (ref($val) && ref($val) eq 'CODE') {
        local $_ = $node;
        return $val->($node);
    } elsif (blessed($val) && $val->isa('Web::Scraper')) {
        return $val->scrape($node, $uri);
    } elsif ($val =~ s!^@!!) {
        my $value = $node->attr($val);
        if ($uri && is_link_element($node, $val)) {
            require URI;
            $value = URI->new_abs($value, $uri);
        }
        return $value;
    } elsif (lc($val) eq 'content' || lc($val) eq 'text') {
        return $node->text_content;
    } elsif (lc($val) eq 'raw' || lc($val) eq 'html') {
        my($html, $has_container) = $node->to_html;
        if ($has_container) {
            $html =~ s!^<.*?>!!;
            $html =~ s!\s*</\w+>\n*$!!;
        }
        return $html;
    } elsif (ref($val) eq 'HASH') {
        my $values;
        for my $key (keys %$val) {
            $values->{$key} = __get_value($node, $val->{$key}, $uri);
        }
        return $values;
    } elsif (ref($val) eq 'ARRAY') {
        my $how   = $val->[0];
        my $value = __get_value($node, $how, $uri);
        for my $filter (@$val[1..$#$val]) {
            $value = run_filter($value, $filter);
        }
        return $value;
    } else {
        Carp::croak "Unknown value type $val";
    }
}

sub run_filter {
    my($value, $filter) = @_;

    ## sub { s/foo/bar/g } is a valid filter
    ## sub { DateTime::Format::Foo->parse_string(shift) } is valid too
    my $callback;
    my $module;

    if (ref($filter) eq 'CODE') {
        $callback = $filter;
        $module   = "$filter";
    } elsif (!ref($filter)) {
        $module = $filter =~ s/^\+// ? $filter : "Web::Scraper::Filter::$filter";
        unless ($module->isa('Web::Scraper::Filter')) {
            $module->require or Carp::croak("Loading $module: $@");
        }
        $callback = sub { $module->new->filter(shift) };
    } elsif (blessed($filter) && $filter->can('filter')) {
        $callback = sub { $filter->filter(shift) };
    } else {
        Carp::croak("Don't know filter type $filter");
    }

    local $_ = $value;
    my $retval = eval { $callback->($value) };
    if ($@) {
        Carp::croak("Filter $module had an error: $@");
    }

    no warnings 'uninitialized';
    # sub { s/foo/bar/ } returns number or PL_sv_no which is stringified to ''
    if (($retval =~ /^\d+$/ and $_ ne $value) or (defined($retval) and $retval eq '')) {
        $value = $_;
    } else {
        $value = $retval;
    }

    return $value;
}

sub is_link_element {
    my($node, $attr) = @_;
    my $tag = $node->tag;
    my $link_elements = $HTML::Tagset::linkElements{$tag} || [];
    for my $elem (@$link_elements) {
        return 1 if $attr eq $elem;
    }
    return;
}

sub __stub {
    my $func = shift;
    return sub {
        croak "Can't call $func() outside scraper block";
    };
}

*process       = __stub 'process';
*process_first = __stub 'process_first';
*result        = __stub 'result';

1;
__END__

=for stopwords API SCRAPI Scrapi

=head1 NAME

Web::Scraper - Web Scraping Toolkit inspired by Scrapi

=head1 SYNOPSIS

  use URI;
  use Web::Scraper;

  my $ebay_auction = scraper {
      process "h3.ens>a",
          description => 'TEXT',
          url => '@href';
      process "td.ebcPr>span", price => "TEXT";
      process "div.ebPicture >a>img", image => '@src';
  };

  my $ebay = scraper {
      process "table.ebItemlist tr.single",
          "auctions[]" => $ebay_auction;
      result 'auctions';
  };

  my $res = $ebay->scrape( URI->new("http://search.ebay.com/apple-ipod-nano_W0QQssPageNameZWLRS") );

=head1 DESCRIPTION

Web::Scraper is a web scraper toolkit, inspired by Ruby's equivalent Scrapi.

B<THIS MODULE IS IN ITS BETA QUALITY. THE API IS STOLEN FROM SCRAPI BUT MAY CHANGE IN THE FUTURE>

=head1 AUTHOR

Tatsuhiko Miyagawa E<lt>miyagawa@bulknews.netE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<http://blog.labnotes.org/category/scrapi/>

=cut
