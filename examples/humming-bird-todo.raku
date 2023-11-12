use v6.d;

use HTML::Component::EndpointList;
use Humming-Bird::Core;
use HTML::Component::Boilerplate;
use URI::Encode;
use lib "examples";
use TodoList;
use Todo;
use App;

get('/', -> $request, $response {
    $response.html(App.new.RENDER.HTML);
});

HTML::Component::EndpointList.map-endpoints: {
    if .verb.uc eq "GET" {
        get .path, -> $request, $response {
            $response.html:
                .run-defined(
                    Any,
                    |$request.query.kv.map(*.subst("+", " ").&uri_decode).Map
                ).Str
            ;
            $response.redirect: $_ with .redirect;
        }
    }
}

listen(12345);
