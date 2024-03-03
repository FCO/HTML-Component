use HTML::Component;
use HTML::Component::Endpoint;
use User;

unit class App does HTML::Component;

method RENDER($_) {
  .a: :href(User.create-user.path), { .add-child: "Create User" };
  .ol: {
    for User.^all -> User:D $user {
      .li:
        :htmx-endpoint($user),
        {
          .add-child: $user
        }
      ;
    }
  }
}
