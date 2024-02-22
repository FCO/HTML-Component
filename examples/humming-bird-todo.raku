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
    $response.html(App.new.RENDER(Any).HTML);
});

HTML::Component::EndpointList.map-endpoints: {
    ::("&{.verb.lc}").(.path, -> $request, $response {
        with .run-defined(
            |(
                |$request.query.kv.map(*.subst("+", " ").&uri_decode).Map,
                |$request.params.kv.map(*.subst("+", " ").&uri_decode).Map
            ).Map
        ).Str {
            .&note;
            $response.html: .Str
        }
        $response.redirect: $_ with .redirect;
    })
}

listen(12345);
