package Web::Scraper::Node;
use strict;
use warnings;

sub new {
    my($class, $node) = @_;

    my $sub = $node->isa('XML::LibXML::Element') ? "LibXML" : "HTMLElement";

    bless { node => $node }, "$class\::$sub";
}

sub DESTROY { }

our $AUTOLOAD;
sub AUTOLOAD {
    my $self = shift;
    (my $method = $AUTOLOAD) =~ s/.*:://;
    $self->{node}->$method(@_);
}

package Web::Scraper::Node::LibXML;
use base qw( Web::Scraper::Node );

sub attr {
    my $self  = shift;
    my($attr) = @_;

    $self->{node}->getAttribute(lc($attr));
}

sub text_content {
    my $self = shift;
    $self->{node}->textContent;
}

sub to_html {
    my $self = shift;
    return ($self->{node}->toString, 1);
}

sub tag {
    my $self = shift;
    $self->{node}->localname;
}

package Web::Scraper::Node::HTMLElement;
use base qw( Web::Scraper::Node );

sub attr {
    my $self  = shift;
    my($attr) = @_;
    $self->{node}->attr($attr);
}

sub text_content {
    my $self = shift;
    $self->{node}->isTextNode ? $self->{node}->string_value : $self->{node}->as_text;
}

sub to_html {
    my $self = shift;
    my $node = $self->{node};

    my $html;
    if ($node->isTextNode) {
        if ($HTML::TreeBuilder::XPath::VERSION < 0.09) {
            return HTML::Entities::encode($node->as_XML, q("'<>&));
        } else {
            return $node->as_XML;
        }
    }

    $html = $node->as_XML;
    return ($html, 1);
}

sub tag {
    my $self = shift;
    $self->{node}->tag;
}

1;
