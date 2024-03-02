use HTML::Component::Tag;
use HTML::Component::Encode;
unit class HTML::Component::Tag::Text does HTML::Component::Tag;

has Str $.value;

multi method new(Str() $value) {
  self.new: :$value
}

method HTML {
  html-encode $!value
}
