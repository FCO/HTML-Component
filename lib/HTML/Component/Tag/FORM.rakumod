use HTML::Component::Tag::Node;
use HTML::Component::Tag::Methods::BODY;
use HTML::Component::HTMLAttr;
use HTML::Component::Enums;
use HTML::Component::Endpoint;

unit class HTML::Component::Tag::FORM does HTML::Component::Tag::Node does HTML::Component::Tag::Methods::BODY;

# has Str   @.accept         is html-attr is DEPRECATED;
# has Str   @.accept-charset is html-attr;
# has Str   $.autocapitalize is html-attr;
# has OnOff $.autocomplete   is html-attr;

has HTML::Component::Endpoint $.endpoint;
has Str()                     $.action     is html-attr = $!endpoint.?path-call;
has Str()                     $.method     is html-attr = $!endpoint.?verb;
has Str()                     $.enctype    is html-attr;
has Bool                      $.novalidate is html-attr;
has Str()                     $.target     is html-attr;
