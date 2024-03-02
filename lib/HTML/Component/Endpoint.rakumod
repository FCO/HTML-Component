use HTML::Component::EndpointList;
unit class HTML::Component::Endpoint;

has Str()   $.verb             = "GET";
has         &.method           is required;
has Str     $.method-name      = &!method.name;
has         $.class            = &!method.package;
has Str     $.class-name       = $!class.^name;
has Capture $.capture          = \();
has         $.load-meth        = "LOAD";
has Bool    $.undefined        = &!method.signature.params.first.modifier ne ":D";
has Bool    $.defined          = &!method.signature.params.first.modifier ne ":U";
has         &.return           = -> :$component, :$method-output { $method-output };
has Bool()  $.return-component = False;
has Str()   $.path             = "/{ $!class.^name.subst("::", "-", :g) }/:id/{ &!method.name }";
has Str()   $.path-call is rw  = $!path;
has         $.redirect;
has         &.on-error;

submethod TWEAK(|) {
  HTML::Component::EndpointList.add-endpoint: self
}

multi method matches(|) {
  False
}

multi method matches(:$verb!) {
  $!verb eq $verb;
}

multi method matches(:$method!) {
  $!method-name eq $method;
}

multi method matches(:$class!) {
  $!class-name eq $class;
}

multi method matches(:$id! where *.so) {
  $!defined
}

multi method matches(:$id! where *.not) {
  $!undefined
}

method gist {
  "{ $!verb } { $!path }"
}

method load(|c) {
  my $meth = $!load-meth;
  $!class."$meth"(|c);
}

sub new-snippet {
  require ::("HTML::Component::Tag::SNIPPET");
  ::("HTML::Component::Tag::SNIPPET").new;
}

sub render($component is copy) {
  $component .= RENDER: new-snippet if $component.^can: "RENDER";
  $component
}

method handle(Capture $data, $component) {
  my Capture $cap .= new: :hash(%(|$!capture.hash, |$data.hash)), :list[|$!capture.list, |$data.list];
  CATCH {
    default {
      with &!on-error {
        my $new-snippet = new-snippet;
        my $*HTML-COMPONENT-RENDERING = True;
        my $err = &!on-error.($new-snippet, |$cap);
        my $ret = render $err;
        $ret .= HTML if $ret.^can: "HTML";
        return $ret;
      } else {
        .rethrow
      }
    }
  }
  my $method-output = $component."{&!method.name}"(|$cap);
  if $!return-component {
    $method-output = render $component;
  }
  my $ret = &!return.(:$component, :$method-output);
  $ret .= &render;
  $ret .= HTML if $ret.^can: "HTML";
  $ret
}

method run-defined(|data) { self.handle: data, $.load(|data) }

method run-undefined(|data) { self.handle: data, $!class }

multi trait_mod:<is>(Method $method, :%endpoint!) is export {
  my HTML::Component::Endpoint $endpoint .= new: :$method, |%endpoint;
  HTML::Component::EndpointList.add-endpoint: $endpoint;
  $method.wrap: my method (|c) {
    if $*HTML-COMPONENT-RENDERING {
      if self.defined {
        $endpoint .= clone: :path-call($endpoint.path.subst: /":id"/, self.id // "");
      } else {
        $endpoint .= clone: :path-call($endpoint.path.subst: /":id/"/, "");
      }
      return $endpoint
    } elsif !self.defined {
        $endpoint .= clone: :path-call($endpoint.path.subst: /":id/"/, "")
    }
    nextsame
  }
}

multi trait_mod:<is>(Method $method, :$endpoint!) is export {
  trait_mod:<is>($method, :endpoint{})
}
