package Web::Scraper;
use strict;
use warnings;
use Carp;
use Scalar::Util 'blessed';
use HTML::TreeBuilder::XPath;
use HTML::Selector::XPath;

our $VERSION = '0.01';

sub import {
    my $class = shift;
    my $pkg   = caller;

    no strict 'refs';
    *{"$pkg\::scraper"} = \&scraper;
    *{"$pkg\::process"} = sub { goto &process };
    *{"$pkg\::result"}  = sub { goto &result  };
}

my $ua;

sub __ua {
    require LWP::UserAgent;
    $ua ||= LWP::UserAgent->new(agent => __PACKAGE__ . "/" . $VERSION);
    $ua;
}

sub scraper(&) {
    my($coderef) = @_;

    sub {
        my $stuff = shift;

        if (blessed($stuff) && $stuff->isa('URI')) {
            require HTTP::Response::Encoding;
            my $ua  = __ua;
            my $res = $ua->get($stuff);
            if ($res->is_success) {
                $stuff = $res->decoded_content;
            } else {
                croak "GET $stuff failed: ", $res->status_line;
            }
        }

        my $tree = HTML::TreeBuilder::XPath->new;
        $tree->parse($stuff);

        my $stash;

        my $get_value = sub {
            my($node, $val) = @_;

            if (ref($val) && ref($val) eq 'CODE') {
                return $val->($node->as_HTML);
            } elsif ($val =~ s!^@!!) {
                return $node->attr($val);
            } elsif ($val eq 'content') {
                return $node->as_text;
            } else {
                Carp::cluck "WTF";
            }
        };

        no warnings 'redefine';
        local *process = sub {
            my($exp, @attr) = @_;

            my $xpath = HTML::Selector::XPath::selector_to_xpath($exp);
            my @nodes = $tree->findnodes($xpath) or return;

            while (my($key, $val) = splice(@attr, 0, 2)) {
                if ($key =~ s!\[\]$!!) {
                    $stash->{$key} = [ map $get_value->($_, $val), @nodes ];
                } else {
                    $stash->{$key} = $get_value->($nodes[0], $val);
                }
            }

            return;
        };

        local *result = sub {
            my @keys = @_;

            if (@keys == 1) {
                return $stash->{$keys[0]};
            } else {
                my %res;
                @res{@keys} = @{$stash}{@keys};
                return \%res;
            }
        };

        my $ret = $coderef->($tree);

        # check user specified return value
        return $ret if $ret;

        return $stash;
    };
}

sub process {
    croak "Can't call process() outside scraper block";
}

sub result {
    croak "Can't call result() outside scraper block";
}

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
          description => 'content',
          url => '@href';
      process "td.ebcPr>span", price => "content";
      process "div.ebPicture >a>img", image => '@src';

      result 'description', 'url', 'price', 'image';
  };

  my $ebay = scraper {
      process "table.ebItemlist tr.single",
          "auctions[]" => $ebay_auction;
      result 'auctions';
  };

  $ebay->( URI->new("http://search.ebay.com/apple-ipod-nano_W0QQssPageNameZWLRS") );

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
