# form auto generation

Example showing how to auto-generate form based on endpoint.

## examples/users/App.rakumod

```raku
use HTML::Component;
use HTML::Component::Endpoint;
use HTML::Component::Boilerplate;
use User;

unit class App does HTML::Component;

method RENDER($_) {
  boilerplate
    :body{
      .a: :endpoint(User), { .add-child: "Create User" };
      .ol: {;
        for User.^all -> User:D $user {
          .li: {
            .add-child: $user
          }
        }
      }
    }
  ;
}
```

## examples/users/User.rakumod

```raku
use HTML::Component;
use HTML::Component::Endpoint;
use Red;

unit model User does HTML::Component is endpoint;

has UInt $.id     is serial;
has Str  $.name   is unique;
has Str  $.email  is column;
has Bool $.active is column = True;

method LOAD(UInt() :$id) {
  self.^load: $id
}

multi method RENDER(::?CLASS:U: $_, $data = Nil) {
  .form: self.create-user, $data
}

multi method RENDER(::?CLASS:D: $_, %data) {
  self.WHAT.RENDER: $_, %data
}

multi method RENDER(::?CLASS:D: $_) {
  .ol: {
    .li: "name : { $!name }";
    .li: "email: { $!email }";
    .li: $!active ?? "ACTIVE" !! "INACTIVE"
  }
}

method create-user(
  Str()  :$name!  where *.chars > 0,     #= Username
  Str()  :$email! where *.contains("@"), #= New user's email
  Bool() :$active = True,
) is endpoint{
  :verb<POST>,
  :redirect</>,
  :on-error(-> $snippet, *%pars {
    self.RENDER: $snippet, %pars
  }),
} {
  ::?CLASS.^create: :$name, :$email, :$active
}
```

## examples/users/users.raku

```raku
use Cro::HTTP::Log::File;
use Cro::HTTP::Server;
use Cro::HTTP::Router;
use HTML::Component::CroRouter;
use Cro::HTTP::Log::File;
use lib "examples";
use App;
use User;
use Red;

red-defaults "SQLite";
# PROCESS::<$RED-DEBUG> = True;

schema(User).create;

User.^create(name => "John", email => "john.doe@domain.com");
User.^create(name => "Jane", email => "jane.doe@domain.com");

my $app = Cro::HTTP::Server.new(
    host => '127.0.0.1',
    port => 10000,
    application => route {
        root-component App.new
    },
);

$app.start;
say "Listening at http://127.0.0.1:10000";

react whenever signal(SIGINT) {
  $app.stop;
  exit;
}
```
