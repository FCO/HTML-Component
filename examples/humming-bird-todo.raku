use v6.d;

use Humming-Bird::Core;
use HTML::Component::Boilerplate;
use lib "examples";
use TodoList;
use Todo;
use App;
use HTML::Component::Endpoint;

my $index = App.new.RENDER;
my $html = $index.HTML;

get('/', -> $request, $response {
    $response.html(App.new.RENDER.HTML);
});

for HTML::Component::Endpoint.endpoints {
    if .verb.uc eq "GET" {
        get .path, -> $request, $response {
            $response.html: .run-defined(Any, |$request.query<>).Str;
            $response.redirect: $_ with .redirect;
        }
    }
}

listen(12345);
