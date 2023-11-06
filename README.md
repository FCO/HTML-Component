[![Actions Status](https://github.com/FCO/HTML-Component/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/HTML-Component/actions)

# NAME

HTML::Components - is the begining of components (WiP)

# SYNOPSIS

```raku
# examples/Todo.rakumod
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
```

```raku
# examples/TodoList.rakumod
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
```

```raku
# humming-bird-todo.raku
use v6.d;

use Humming-Bird::Core;
use HTML::Component::Boilerplate;
use lib "examples";
use TodoList;
use Todo;
use HTML::Component::Endpoint;

my $index = boilerplate :title("My TODO list"), { .add-child: TodoList.new }
my $html = $index.HTML;

get('/', -> $request, $response {
    $response.html($html);
});

for HTML::Component::Endpoint.endpoints {
    if .verb.uc eq "GET" {
        get .path, -> $request, $response {
            $response.html: .run-defined(Any, |$request.query<>)
        }
    }
}

listen(12345);

```

# DESCRIPTION

HTML::Components is comming...

# AUTHOR

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

# COPYRIGHT AND LICENSE

Copyright 2023 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
