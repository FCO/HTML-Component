unit class HTML::Component::Endpoint;

my @endpoints;

method endpoints { @endpoints }

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
  @endpoints.push: self
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
  $method.wrap: my method (|c) {
    state HTML::Component::Endpoint $endpoint .= new: :$method, |%endpoint;
    if $*HTML-COMPONENT-RENDERING {
      return $endpoint
    }
    nextsame
  }
}
