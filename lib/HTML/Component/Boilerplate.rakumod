use HTML::Component;

unit class HTML::Component::Boilerplate does HTML::Component;

has Bool $.doctype = True;
has Bool $.charset = True;
has Str  $.viewport = "width=device-width, initial-scale=1.0";
has Str  $.x-ua-compatible = "ie=edge";
has Str  $.title = "HTML::Component title";
has      @.style-sheets;
has Str  $.icon;
has      &.body = -> $ {}


method RENDER {
  html {
    .head: {
      .meta-charset if $!charset;
      .meta: :name<viewport>, :content($!viewport) if $!viewport;
      .meta-http-equiv: "X-UA-Compatible", $!x-ua-compatible if $!x-ua-compatible;
      .title: $!title if $!title;
      for @!style-sheets -> $href { .link: :rel<stylesheet>, :$href }
      .link: :rel<icon>, :href($_), :type<image/x-icon> with $!icon;
    }
    .body: &!body
  }
}

sub boilerplate(&body = -> $ {}, *%_) is export {
  HTML::Component::Boilerplate.new(:&body, |%_).RENDER
}
