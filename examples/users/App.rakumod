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
