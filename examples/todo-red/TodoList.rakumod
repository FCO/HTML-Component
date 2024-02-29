use HTML::Component::Endpoint;
use HTML::Component;
use HTML::Component::Boilerplate;
use HTML::Component::Traits;
use Red;

unit model TodoList does HTML::Component;

method LOAD(:$id) { self.^load: $id }

has UInt $.id    is serial;
has      @.todos is relationship( *.list-id, :model<Todo> );

method RENDER($_) {
  .ol: {
    .add-children: @!todos.Seq;
  }
  .form: self.new-todo;
}

method new-todo(
  Str :$description! is no-label, #= What should be done?
) is endpoint{ :verb<POST>, :redirect</> } {
  @!todos.create: :$description;
}
