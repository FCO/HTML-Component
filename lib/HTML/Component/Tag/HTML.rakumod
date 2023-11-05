use HTML::Component::Tag::Node;
use HTML::Component::Tag::Methods::HTML;

unit class HTML::Component::Tag::HTML does HTML::Component::Tag::Node does HTML::Component::Tag::Methods::HTML;

has Bool $.doctype = True;

::?CLASS.^find_method("HTML").wrap: my method (|) {
  join "\n", |('<!DOCTYPE html>' if $!doctype), callsame
}
