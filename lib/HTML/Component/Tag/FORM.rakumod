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

multi method new(
  HTML::Component::Endpoint $endpoint!,
  $data = Nil,
  Str() :$submit-value,
  Bool() :$add-submit = True,
  *%attrs
) {
  do given self.new(:$endpoint, |%attrs) {
    for $endpoint.method.signature.params.grep: { .named && !.slurpy } -> $param {
      my Str() $id    = $param.WHICH;
      my Str() $name  = $param.usage-name.subst: "-", "_", :g;
      my       $value = $_ with $data{$name} // ( $param.default andthen .() );
      my Str() $label = $param.?label // $param.usage-name.subst("-", " ", :g).tclc;

      given $_ {
        when $param.type ~~ Str {
          .label:
            :for($id),
            $param.usage-name.subst("-", " ", :g).tclc,
          unless $param.?no-label;
          .input-text:
            :$name,
            :$id,
            |(:value($_) with $value),
            |(:placeholder($_) with $param.WHY)
          ;
        }
        when $param.type ~~ Bool {
          .input-checkbox:
            :$name,
            :$id,
            |(:checked($_) with $value)
          ;
          .label:
            :for($id),
            $param.usage-name.subst("-", " ", :g).tclc,
          unless $param.?no-label;
        }
      }
      if $data.DEFINITE && ( $data{$name} !~~ ($param.type & $param.constraints) ) {
        .br;
        .span: "$name is invalid"
      }
      .br;
    }
    .input-submit: $submit-value if $add-submit;
    $_
  }
}
