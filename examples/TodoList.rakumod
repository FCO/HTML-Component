use HTML::Component;
use HTML::Component::Endpoint;
use HTML::Component::Boilerplate;
use Todo;

unit class TodoList does HTML::Component;

method new(|)   { $ //= self.bless }
method LOAD($?) { self.new }

has Todo @.todos;

method RENDER($_) {
  .ol: {
    for @!todos -> Todo $todo {
      .add-child: $todo
    }
  }
  .form:
    :endpoint(self.new-todo),
    {
      .input: :type<text>, :name<description>;
      .input: :type<submit>;
    }
}

method new-todo(Str :$description!)
is endpoint{
  :path</bla>,
  :return(-> | { boilerplate :title("My TODO list"), { .add-child: TodoList.new } })
} {
  @!todos.push: Todo.new: :$description;
}
