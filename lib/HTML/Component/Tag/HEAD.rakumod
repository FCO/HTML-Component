use HTML::Component::Tag::Node;
use HTML::Component::HTMLAttr;
use HTML::Component::Enums;
use HTML::Component::Tag::Methods::HEAD;

unit class HTML::Component::Tag::HEAD does HTML::Component::Tag::Node does HTML::Component::Tag::Methods::HEAD;

has URL @.profile is html-attr is DEPRECATED;
