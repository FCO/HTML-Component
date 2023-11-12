no precompilation;
unit class HTML::Component::EndpointList;

my @endpoints;

method new { $ //= self.bless }

method add-endpoint(|c) { @endpoints.push: |c }

method map-endpoints(|c) { @endpoints.map: |c }

method list { @endpoints }
