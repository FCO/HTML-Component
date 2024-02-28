# `HTML::Component` + `Cro` + `Red`

An option to store component's state is saving it on DB, and a easy way it to
use Red. Here is an example of one way that's possible, just creating the
components as models.

# Code

## App.rakumod

```raku
use TodoList;
use HTML::Component;
use HTML::Component::Boilerplate;
unit class App does HTML::Component;

has TodoList $.todo-list = TodoList.^all.head;

method RENDER($) {
  boilerplate
    :title("My TODO list"),
    :body{
      .script: :src<https://unpkg.com/htmx.org@1.9.10>;
      .add-child: $!todo-list;
    }
}
```
## Todo.rakumod

```raku
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
```

## TodoList.rakumod

```raku
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
```

## cro-todo.raku

```raku
use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use HTML::Component::CroRouter;
use Cro::HTTP::Log::File;
use lib "examples";
use App;
use TodoList;
use Todo;
use Red;

red-defaults "SQLite";
PROCESS::<$RED-DEBUG> = True;

schema(TodoList, Todo).create;

TodoList.^create;

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
