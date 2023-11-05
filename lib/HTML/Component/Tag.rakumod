use HTML::Component;

unit role HTML::Component::Tag does HTML::Component;

# multi method COERCE(Str $value) {
#   require ::("HTML::Component::Tag::Text");
#   ::("HTML::Component::Tag::Text").new: :$value
# }

multi method new(*%_ where *.keys (-) self.^attributes.map: *.name.substr(2)) {
  die "Attribute(s) { %_.keys (-) self.^attributes.map: *.name.substr: 2 } invalid for { self.^name }"
}
