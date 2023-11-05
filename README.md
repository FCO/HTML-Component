[![Actions Status](https://github.com/FCO/HTML-Component/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/HTML-Component/actions)

# NAME

HTML::Components - is the begining of components (WiP)

# SYNOPSIS

```raku
# examples/Todo.rakumod
use HTML::Component;

unit class Todo does HTML::Component;

has Str()  $.description is required;
has Bool() $.done = False;
has        $!parent is built;

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
```

```raku
# examples/TodoList.rakumod
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
```

```raku
# running
use HTML::Component::Boilerplate;
use lib "examples";
use TodoList;
use Todo;

given boilerplate
    :title("My TODO list"),
    {
        .add-child: TodoList.new: :todos( ^5 .map: { Todo.new: "todo $_" } )
    }
{
    say .HTML
}

```

```output
<!DOCTYPE html>
<html>
    <head>
        <meta charset='utf-8'>
        <meta name='viewport' content='width=device-width, initial-scale=1.0'>
        <meta http-equiv='X-UA-Compatible' content='ie=edge'>
        <title>
            My TODO list
        </title>
    </head>
    <body>
        <ol>
            <li class='todo'>
                <input type='checkbox'>
                todo 0
            </li>
            <li class='todo'>
                <input type='checkbox'>
                todo 1
            </li>
            <li class='todo'>
                <input type='checkbox'>
                todo 2
            </li>
            <li class='todo'>
                <input type='checkbox'>
                todo 3
            </li>
            <li class='todo'>
                <input type='checkbox'>
                todo 4
            </li>
        </ol>
    </body>
</html>
```

# DESCRIPTION

HTML::Components is comming...

# AUTHOR

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

# COPYRIGHT AND LICENSE

Copyright 2023 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
