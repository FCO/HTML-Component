use HTML::Component::HTMLAttr;
use HTML::Component::Tag::Leaf;
use HTML::Component::Helpers;
use HTML::Component::Enums;

class HTML::Component::Tag::META-NAME       {...}
class HTML::Component::Tag::META-CHARSET    {...}
class HTML::Component::Tag::META-HTTP-EQUIV {...}
class HTML::Component::Tag::META does HTML::Component::Tag::Leaf {
  multi method new(:$charset!)         { HTML::Component::Tag::META-CHARSET.new }
  multi method new(:$name!, *%_)       { HTML::Component::Tag::META-NAME.bless: :$name, |%_ }
  multi method new(:$http-equiv!, *%_) { HTML::Component::Tag::META-HTTP-EQUIV.bless: :$http-equiv, |%_ }
  method tag-name { "meta" }
}

class HTML::Component::Tag::META-CHARSET is HTML::Component::Tag::META {
  has $.charset is html-attr = "utf-8";
}

class HTML::Component::Tag::META-NAME is HTML::Component::Tag::META {
  has Str() $.name    is html-attr is required;
  has Str() $.content is html-attr is required;
}

class HTML::Component::Tag::META-HTTP-EQUIV is HTML::Component::Tag::META does HTML::Component::PositionalsToValues["http-equiv", "content"] {
  has Str() $.http-equiv is html-attr is required;
  has Str() $.content    is html-attr is required;
}
