use HTML::Component::Tag::Node;
use HTML::Component::HTMLAttr;

unit class HTML::Component::Tag::SCRIPT does HTML::Component::Tag::Node;

has $.src is html-attr;
