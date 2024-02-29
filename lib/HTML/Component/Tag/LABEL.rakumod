use HTML::Component::Tag::Node;
use HTML::Component::Tag::Methods::BODY;
use HTML::Component::HTMLAttr;

unit class HTML::Component::Tag::LABEL does HTML::Component::Tag::Node does HTML::Component::Tag::Methods::BODY does HTML::Component::PositionalAsChild;

has $.for is html-attr;
