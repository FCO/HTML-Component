use HTML::Component;
use Todo;

unit class TodoList does HTML::Component;

has Todo @.todos;

method RENDER($_) {
  .ol: {
    for @!todos -> Todo $todo {
      .add-child: $todo
    }
  }
  ;
}

