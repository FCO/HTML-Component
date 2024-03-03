use HTML::Component::EndpointList;
unit class HTML::Component::Endpoint;

has Str()   $.verb             = "GET";
has         &.method;
has Str     $.method-name      = &!method ?? &!method.name !! Nil;
has         $.class            = &!method.package;
has Str     $.class-name       = $!class.^name;
has Capture $.capture          = \();
has         $.load-meth        = "LOAD";
has Bool    $.undefined        = &!method ?? &!method.signature.params.first.modifier ne ":D" !! True;
has Bool    $.defined          = &!method ?? &!method.signature.params.first.modifier ne ":U" !! True;
has         &.return           = -> :$component, :$method-output { $method-output };
has Bool()  $.return-component = False;
has Str()   $.path             = "/{ $!class.^name.subst("::", "-", :g) }/:id{ "/{ &!method.name }" if &!method }";
has Str()   $.path-call is rw  = $!path;
has         $.redirect;
has         &.on-error;

multi method new($from) {
  HTML::Component::EndpointList.endpoint-from-component($from.WHAT).transform($from)
}

submethod TWEAK(|) {
  HTML::Component::EndpointList.add-endpoint: self
}

multi method matches(|) {
  False
}

multi method matches(:$verb!) {
  $!verb eq $verb;
}

multi method matches(:$method! where *.not) {
  &!method.defined.not;
}

multi method matches(:$method!) {
  $!method-name andthen * eq $method;
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
  my $*HTML-COMPONENT-RENDERING = True without &!method;
  my Capture $cap .= new: :hash(%(|$!capture.hash, |$data.hash)), :list[|$!capture.list, |$data.list];
  CATCH {
    default {
      if &!on-error {
        my $new-snippet = new-snippet;
        my $err = &!on-error.($new-snippet, |$cap);
        my $ret = render $err;
        $ret .= HTML if $ret.^can: "HTML";
        return $ret;
      } else {
        .rethrow
      }
    }
  }
  my $method-output = &!method.defined ?? $component."{&!method.name}"(|$cap) !! $component;
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

method transform($component) {
  do if $*HTML-COMPONENT-RENDERING {
    do if $component.defined {
      self.clone: :path-call(self.path.subst: /":id"/, $component.id // "");
    } else {
      self.clone: :path-call(self.path.subst: /":id/"/, "");
    }
  } elsif !$component.defined {
      self.clone: :path-call(self.path.subst: /":id/"/, "")
  } else {
    self
  }
}

multi trait_mod:<is>(Method $method, :%endpoint!) is export {
  my HTML::Component::Endpoint $endpoint .= new: :$method, |%endpoint;
  HTML::Component::EndpointList.add-endpoint: $endpoint;
  $method.wrap: my method (|c) {
    return $endpoint.transform: self if $*HTML-COMPONENT-RENDERING;
    nextsame
  }
}

multi trait_mod:<is>(Method $method, :$endpoint!) is export {
  trait_mod:<is>($method, :endpoint{})
}

multi trait_mod:<is>(Mu:U $component, :%endpoint!) is export {
  my HTML::Component::Endpoint $endpoint .= new: :class($component), |%endpoint;
  HTML::Component::EndpointList.add-endpoint: $endpoint;
}

multi trait_mod:<is>(Mu:U $component, :$endpoint!) is export {
  trait_mod:<is>($component, :endpoint{})
}
