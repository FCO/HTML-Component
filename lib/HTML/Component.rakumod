unit role HTML::Component;

sub html(|c) is export {
  require ::("HTML::Component::Tag::HTML");
  ::("HTML::Component::Tag::HTML").new: |c;
}

method HTML {
  my $*HTML-COMPONENT-RENDERING = True;
  $.RENDER: CALLERS::<self>;
  Empty
}
