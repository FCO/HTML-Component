use HTML::Component::Endpoint;
use HTML::Component;
use HTML::Component::Boilerplate;
use HTML::Component::Traits;
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
  .form: self.new-todo;
}

method new-todo(
  Str :$description! is no-label, #= What should be done?
) is endpoint{ :verb<POST>, :redirect</> } {
  @!todos.push: Todo.new: :$description;
}
