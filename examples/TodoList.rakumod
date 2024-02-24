use HTML::Component::Endpoint;
use HTML::Component;
use HTML::Component::Boilerplate;
use Todo;

unit class TodoList does HTML::Component;

method new(|)  { $ //= self.bless }
method LOAD(|) { self.new }

has UInt $.id = ++$;
has Todo @.todos;

method RENDER($_) {
  .ol: {
    .add-children: @!todos;
  }
  .form:
    :endpoint(self.new-todo),
    {
      .input: :type<text>, :name<description>;
      .input: :type<submit>;
    }
}

method new-todo(Str :$description!) is endpoint{ :verb<POST>, :redirect</> } {
  @!todos.push: Todo.new: :$description;
}
