unit role HTML::Component;

sub html(|c) is export {
  require ::("HTML::Component::Tag::HTML");
  ::("HTML::Component::Tag::HTML").new: |c;
}

# sub body(&func, *%_ where { .keys.all ~~ BODY.&all-html-attrs.any }) is export {
#     my $body = BODY.new: |%_;
#     $body.&func;
#     $body
# }

#class SNIPPET does OnOl does OnBody does OnHTML does OnHead does Node {}

# sub snippet(&func) is export {
#     #do given func SNIPPET.new { .children.head }
#     func SNIPPET.new # for now
# }

method HTML {
  my $*HTML-COMPONENT-RENDERING = True;
  $.RENDER: CALLERS::<self>;
  Empty
}

# method render-root {
#     html -> HTML::Component $root { self.RENDER: $root }
# }
# method render {
#     snippet(-> HTML::Components $root { self.RENDER: $root }).RENDER
# }
