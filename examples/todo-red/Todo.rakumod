use HTML::Component;
use HTML::Component::Endpoint;
use Red;

unit model Todo does HTML::Component;

has UInt   $.id          is serial;
has Str()  $.description is column;
has Bool() $.done        is column is rw = False;
has UInt   $.list-id     is referencing( *.id, :model<TodoList> );
has        $.list        is relationship{ .list-id };

method LOAD(UInt() :$id) {
  self.^load: $id
}

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
  $!done .= not;
  self.^save
}
