# form auto generation

Example showing how to auto-generate form based on endpoint.

## examples/users/User.rakumod

```raku
use HTML::Component;
use HTML::Component::Endpoint;
use Red;

unit model User does HTML::Component;

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
use User;
use Red;

red-defaults "SQLite";
# PROCESS::<$RED-DEBUG> = True;

schema(User).create;

my $app = Cro::HTTP::Server.new(
    host => '127.0.0.1',
    port => 10000,
    application => route {
        root-component User
    },
  );

  $app.start;
  say "Listening at http://127.0.0.1:10000";

  react whenever signal(SIGINT) {
      $app.stop;
      exit;
  }
```
