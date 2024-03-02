use HTML::Component;
use HTML::Component::Endpoint;
use Red;

unit model User does HTML::Component;

has UInt $.id     is serial;
has Str  $.name   is unique;
has Str  $.email  is column;
has Bool $.active is column = True;

method LOAD(UInt() :$id) {
  self.^load: $id
}

multi method RENDER(::?CLASS:U: $_, $data = Nil) {
  .form: self.create-user, $data
}

multi method RENDER(::?CLASS:D: $_, %data) {
  self.WHAT.RENDER: $_, %data
}

multi method RENDER(::?CLASS:D: $_) {
  .ol: {
    .li: "name : { $!name }";
    .li: "email: { $!email }";
    .li: $!active ?? "ACTIVE" !! "INACTIVE"
  }
}

method create-user(
  Str()  :$name!  where *.chars > 0,     #= Username
  Str()  :$email! where *.contains("@"), #= New user's email
  Bool() :$active = True,
) is endpoint{
  :verb<POST>,
  :on-error(-> $snippet, *%pars {
    self.RENDER: $snippet, %pars
  }),
} {
  ::?CLASS.^create: :$name, :$email, :$active
}
