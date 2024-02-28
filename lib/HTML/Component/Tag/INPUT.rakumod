use HTML::Component::Tag::Leaf;
use HTML::Component::HTMLAttr;
use HTML::Component::Enums;

class HTML::Component::Tag::INPUT does HTML::Component::Tag::Leaf {
  # TODO: add all attributes
  has Str() $.name is html-attr;
  has Str() $.type is html-attr;

  method tag-name { "input" }
}

class HTML::Component::Tag::INPUT-CHECKBOX is HTML::Component::Tag::INPUT {
  has InputType $.type    is html-attr = checkbox;
  has Bool()    $.checked is html-attr;
}
