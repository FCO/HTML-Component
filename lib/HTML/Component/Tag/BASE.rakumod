use HTML::Component::Tag::Leaf;
use HTML::Component::HTMLAttr;
use HTML::Component::Enums;
use HTML::Component::Helpers;

unit class HTML::Component::Tag::BASE does HTML::Component::Tag::Leaf does HTML::Component::PositionalsToValues["href", "target"];

  has URL    $.href   is html-attr is required;
  has Target $.target is html-attr;
