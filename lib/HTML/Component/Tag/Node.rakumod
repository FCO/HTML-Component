use HTML::Component::Tag::Leaf;
use HTML::Component::Tag::Text;
# use HTML::Component;

unit role HTML::Component::Tag::Node is HTML::Component::Tag::Leaf;

has @.children;

multi method new(&body, *%_) {
    my $obj = self.new: |%_;
    $obj.&body;
    $obj
}

multi method add-children(+@components) {
    $.add-child: $_ for @components
}

multi method add-child(@components) {
    $.add-child: $_ for @components
}

multi method add-child(HTML::Component $comp) {
    @!children.push: $comp;
    $comp
}

multi method add-child(HTML::Component::Tag::Text() $comp) {
    @!children.push: $comp;
    $comp
}

multi method add-child(&body) {
    self.&body;
    self
}

method HTML(--> Str()) {
    my $*HTML-COMPONENT-RENDERING = True;
    for @!children { .?RENDER: self }
    [
        callsame,
        |@!children.map(*.?HTML).grep(*.defined)».?indent(4),
        "</{ $.tag-name }>"
    ].join: "\n"
}
