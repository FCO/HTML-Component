use HTML::Component;
use HTML::Component::Endpoint;

unit class Todo does HTML::Component;

my @todos;

has UInt   $.id = ++$;
has Str()  $.description is required;
has Bool() $.done = False;

submethod TWEAK(|) {
  @todos[$!id - 1] := self;
}

method LOAD(UInt() :$id) {
  @todos[$id - 1]
}

multi method new($description) { self.new: :$description, |%_ }

method RENDER($_) {
  .li:
    :htmx-endpoint(self.toggle),
    :hx-swap<outerHTML>,
    :class<todo>,
    {
      .input-checkbox:
        :checked($!done),
      ;
      if $!done {
        .del: $!description
      } else {
        .add-child: $!description
      }
    }
  ;
}

method toggle is endpoint{ :return-component } {
  $!done .= not
}
