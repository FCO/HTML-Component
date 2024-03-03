no precompilation;
unit class HTML::Component::EndpointList;

my %endpoints is SetHash;

method new { $ //= self.bless }

method add-endpoint($endpoint) { %endpoints{$endpoint} = True }

method map-endpoints(&block) { %endpoints.keys.map: &block }

method list { %endpoints.keys }

multi method get(*%pars) {
  %endpoints.keys.first: -> $endpoint {
    [&&] %pars.kv.map: -> $key, $value {
      $endpoint.matches: |%($key => $value)
    }
  }
}

method endpoint-from-component($component) {
  self.get:
    :verb<GET>,
    :class($component.^name),
    :!method,
    :!id,
}
