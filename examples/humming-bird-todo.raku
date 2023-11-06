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
