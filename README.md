[![Actions Status](https://github.com/FCO/HTML-Component/actions/workflows/test.yml/badge.svg)](https://github.com/FCO/HTML-Component/actions)

Still very early stage of development
=====================================

NAME
====

`HTML::Component` - is the beginning of components (WiP)

SYNOPSIS
========

```raku
# examples/todo/Todo.rakumod
use HTML::Component;
use HTML::Component::Endpoint;

unit class Todo does HTML::Component;

my @todos;

has UInt   $.id = ++$;
has Str()  $.description is required;
has Bool() $.done = False;

submethod TWEAK(|) {
  @todos[$!id - 1] := self;
}

method LOAD(UInt() :$id) {
  @todos[$id - 1]
}

multi method new($description) { self.new: :$description, |%_ }

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
  $!done .= not
}
```

```raku
# examples/todo/TodoList.rakumod
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
```

```raku
# examples/todo/App.rakumod
use TodoList;
use HTML::Component;
use HTML::Component::Boilerplate;
unit class App does HTML::Component;

method RENDER($) {
  boilerplate
    :title("My TODO list"),
    :body{
      .script: :src<https://unpkg.com/htmx.org@1.9.10>;
      .add-child: TodoList.new;
    }
  ;
}
```

```raku
# examples/todo/cro-todo.raku
use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use HTML::Component::CroRouter;
use Cro::HTTP::Log::File;
use lib "examples";
use App;

my $route = route {
    root-component App.new
}

my $app = Cro::HTTP::Server.new(
    host => '127.0.0.1',
    port => 10000,
    application => $route,
    after => [
        Cro::HTTP::Log::File.new(logs => $*OUT, errors => $*ERR)
    ],
  );

  $app.start;
  say "Listening at http://127.0.0.1:10000";

  react whenever signal(SIGINT) {
      $app.stop;
      exit;
  }
```

DESCRIPTION
===========

HTML::Component is coming...

AUTHOR
======

Fernando Corrêa de Oliveira `fernandocorrea@gmail.com`

COPYRIGHT AND LICENSE
=====================

Copyright 2023 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.

