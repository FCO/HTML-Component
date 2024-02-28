use HTML::Component::Endpoint;
use HTML::Component;
use HTML::Component::Boilerplate;
use Red;

unit model TodoList does HTML::Component;

method LOAD(:$id) { self.^load: $id }

has UInt $.id    is serial;
has      @.todos is relationship( *.list-id, :model<Todo> );

method RENDER($_) {
  .ol: {
    .add-children: @!todos.Seq;
  }
  .form:
    :endpoint(self.new-todo),
    {
      .input: :type<text>, :name<description>;
      .input: :type<submit>;
    }
}

method new-todo(Str :$description!) is endpoint{ :verb<POST>, :redirect</> } {
  @!todos.create: :$description;
}
