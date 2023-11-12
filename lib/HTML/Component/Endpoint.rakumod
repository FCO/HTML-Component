use HTML::Component::EndpointList;
unit class HTML::Component::Endpoint;

has Str()   $.verb      = "GET";
has Str()   $.path;
has         &.method    is required;
has         $.class     = &!method.package;
has Capture $.capture   = \();
has         $.load-meth = "LOAD";
has Bool    $.undefined = &!method.signature.params.first.modifier ne ":D";
has Bool    $.defined   = &!method.signature.params.first.modifier ne ":U";
has         &.return    = -> :$component, :$method-output { $method-output };
has         $.redirect;

submethod TWEAK(|) {
  HTML::Component::EndpointList.add-endpoint: self
}

method load($id?) {
  my $meth = $!load-meth;
  $!class."$meth"(|($_ with $id));
}

method run-defined($id, |data) {
  my $component     = $.load(|($_ with $id));
  my $method-output = $component."{&!method.name}"(|$!capture, |data);
  my $ret = &!return.(:$component, :$method-output);
  return $ret.HTML if $ret.^can: "HTML";
  $ret
}

method run-undefined(|data) {
  my $component = $!class;
  my $method-output = $!class."{&!method.name}"(|$!capture, |data);
  my $ret = &!return.(:$component, :$method-output);
  return $ret.HTML if $ret.^can: "HTML";
  $ret
}

multi trait_mod:<is>(Method $method, :%endpoint (Str() :$path!, |)) is export {
  my HTML::Component::Endpoint $endpoint .= new: :$method, |%endpoint;
  HTML::Component::EndpointList.add-endpoint: $endpoint;
  $method.wrap: my method (|c) {
    return $endpoint if $*HTML-COMPONENT-RENDERING;
    nextsame
  }
}
