use Cro::HTTP::Router;
use HTML::Component::EndpointList;
use HTML::Component::Tag::SNIPPET;
use HTML::Component;

my &handler = -> $endpoint, $id, $data? {
    my %data is Map = $data.pairs;
    given $id.defined
        ?? $endpoint.run-defined(:$id, |%data)
        !! $endpoint.run-undefined(|%data)
    {
        with $endpoint.redirect {
            redirect :see-other, .Str
        }
        content 'text/html', .Str
    }
}

sub handle($endpoint, :$id) {
    # CATCH { default { say "ERROR: ", .gist } }
    request-body
        "application/x-www-form-urlencoded" => &handler.assuming($endpoint, $id),
        &handler.assuming($endpoint, $id);
    ;
}

sub root-component(HTML::Component $root) is export {
    my HTML::Component::EndpointList $endpoint-list .= new;

    get -> {
        # say "GET /";
        my $*HTML-COMPONENT-RENDERING = True;
        my HTML::Component::Tag::SNIPPET $snippet .= new;
        my Str() $html = $root.?RENDER($snippet);
        content 'text/html', $html;
    }

    get -> Str $class where $endpoint-list.get(:verb<GET>, :$class, :!method, :!id).so {
        # say "GET /class";
        handle $endpoint-list.get(:verb<GET>, :$class, :!method, :!id);
    }

    get -> Str $class, Int $id where $endpoint-list.get(:verb<GET>, :$class, :!method, :id).so {
        # say "GET /class/id";
        handle $endpoint-list.get(:verb<GET>, :$class, :!method, :id), :$id;
    }

    get -> Str $class, Int $id, Str $method where $endpoint-list.get(:verb<GET>, :$class, :$method, :id).so {
        # say "GET /class/id/method";
        handle $endpoint-list.get(:verb<GET>, :$class, :$method, :id), :$id;
    }

    get -> Str $class, Str $method where $endpoint-list.get(:verb<GET>, :$class, :$method, :!id).so {
        # say "GET /class/method";
        handle $endpoint-list.get(:verb<GET>, :$class, :$method, :!id);
    }

    post -> Str $class, Int $id, Str $method where $endpoint-list.get(:verb<POST>, :$class, :$method, :id).so {
        # say "GET /class/id/method";
        handle $endpoint-list.get(:verb<POST>, :$class, :$method, :id), :$id;
    }

    post -> Str $class, Str $method where $endpoint-list.get(:verb<POST>, :$class, :$method, :!id).so {
        say "POST /class/method";
        handle $endpoint-list.get(:verb<POST>, :$class, :$method, :!id);
    }
}

