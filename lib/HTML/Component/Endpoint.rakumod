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

method after-method($component, $method-output is copy) {
  my $*HTML-COMPONENT-RENDERING = True;
  if $!return-component {
    require ::("HTML::Component::Tag::SNIPPET");
    my $snippet = ::("HTML::Component::Tag::SNIPPET").new;
    $component.RENDER: $snippet;
    $method-output = $snippet.HTML;
  }
  my $ret = &!return.(:$component, :$method-output);
  return $ret.HTML if $ret.^can: "HTML";
  $ret
}

method run-defined(|data) {
  my Capture $cap  .= new: :hash(%(|$!capture.hash, |data.hash)), :list[|$!capture.list, |data.list];
  my $component     = $.load(|data);
  my $method-output = $component."{$!method-name}"(|$cap);
  self.after-method: $component, $method-output;
}

method run-undefined(|data) {
  my $component = $!class;
  my Capture $cap  .= new: :hash(%(|$!capture.hash, |data.hash)), :list[|$!capture.list, |data.list];
  my $method-output = $!class."{&!method.name}"(|$cap);
  self.after-method: $component, $method-output;
}

# multi trait_mod:<is>(Method $method, :$endpoint) is export {
#   trait_mod:<is>($method, :endpoint{})
# }

multi trait_mod:<is>(Method $method, :%endpoint) is export {
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
