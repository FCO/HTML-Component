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

  react whenever signal(SIGINT) {
      $app.stop;
      exit;
  }
