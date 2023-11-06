use HTML::Component;

unit class Todo does HTML::Component;

has UInt   $.id = ++$;
has Str()  $.description is required;
has Bool() $.done = False;

multi method new($description) { self.new: :$description, |%_ }

method RENDER($_) {
  .li:
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
