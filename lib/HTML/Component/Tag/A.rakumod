use HTML::Component::Endpoint;
use HTML::Component::Tag::Node;
use HTML::Component::HTMLAttr;
use HTML::Component::Enums;
use HTML::Component::Tag::Methods::BODY;

unit class HTML::Component::Tag::A
  does HTML::Component::Tag::Node
  does HTML::Component::Tag::Methods::BODY
  does HTML::Component::PositionalsToValues["href"]
;

has HTML::Component::Endpoint() $.endpoint;
has $.href    is html-attr = $!endpoint.defined ?? $!endpoint.path-call !! Nil;
has $.onclick is html-attr;
