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

