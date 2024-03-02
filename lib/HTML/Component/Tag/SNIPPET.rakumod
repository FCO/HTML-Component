use HTML::Component::Tag::Node;
use HTML::Component::HTMLAttr;
use HTML::Component::Tag::Methods::BODY;
# use HTML::Component::Tag::Methods::HEAD;
# use HTML::Component::Tag::Methods::HTML;
use HTML::Component::Tag::Methods::OL;

unit class HTML::Component::Tag::SNIPPET
  does HTML::Component::Tag::Methods::BODY
  # does HTML::Component::Tag::Methods::HEAD
  # does HTML::Component::Tag::Methods::HTML
  does HTML::Component::Tag::Methods::OL
  does HTML::Component::Tag::Node
;

method HTML {
  @.children.map({
    do given .?RENDER(self) // $_ {
      .?HTML.Str // .Str // ""
    }
  }).join("\n")
}
