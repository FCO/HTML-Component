use HTML::Component::Tag;
unit class HTML::Component::Tag::Text does HTML::Component::Tag;

has Str $.value;

multi method new(Str() $value) {
  self.new: :$value
}

method HTML {
  $!value
}
