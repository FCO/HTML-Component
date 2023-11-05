use HTML::Component::Tag::Node;
use HTML::Component::HTMLAttr;
use HTML::Component::Enums;
use HTML::Component::Tag::Methods::BODY;

unit class HTML::Component::Tag::A does HTML::Component::Tag::Node does HTML::Component::Tag::Methods::BODY does HTML::Component::PositionalsToValues["href"];

has $.onclick is html-attr;
