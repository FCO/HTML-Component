subset URL of Str;

role HTMLAttr {}
multi trait_mod:<is>(Attribute $attr, :$html-attr!) {
    trait_mod:<is>($attr, :built);
    $attr does HTMLAttr
}

enum AutoCapitalize <off none on sentences words characters>;
enum Dir <ltr rtl dir-auto>;                     # TODO: fix enum
enum YesNo <no yes>;
enum VirtualKeyboardPolicy <policy-auto manual>; # TODO: fix enum
class Text {...}
class HTML::Components {}
class HTML::Components::Tag is HTML::Components {
    multi method new(Str $value) { Text.new: :$value }
}

class Text is Str is HTML::Components::Tag {
    method COERCE(Str $value) { self.new: :$value }

    method RENDER { $.Str }
}

role Leaf is HTML::Components::Tag {
    has Str                   @!access-key       is html-attr;
    has AutoCapitalize()      $!auto-capitalize  is html-attr;
    has Bool                  $!auto-focus       is html-attr;
    has Str                   @!class            is html-attr;
    has Bool                  $!content-editable is html-attr;
    has                       $!context-menu     is html-attr is DEPRECATED;
    has                       %!data             is html-attr;
    has Dir()                 $!dir              is html-attr;
    has Bool                  $!draggable        is html-attr;
    has                       $!enter-key-hint   is html-attr;
    has Bool                  $!hidden           is html-attr;
    has Str                   $!id               is html-attr;
    has Bool                  $!inert            is html-attr;
    has                       $!input-mode       is html-attr;
    has                       $!is               is html-attr;
    has                       $!item-id          is html-attr;
    has Str                   $!item-prop        is html-attr;
    has                       $!item-ref         is html-attr;
    has                       $!item-scope       is html-attr;
    has                       $!item-type        is html-attr;
    has Str                   $!lang             is html-attr;
    has Numeric               $!nonce            is html-attr;
    has Str                   @!part             is html-attr;
    has                       $!pop-over         is html-attr;
    has Str                   $!role             is html-attr; # TODO: Create and use enum
    has Str                   $!slot             is html-attr;
    has Bool                  $!spell-check      is html-attr;
    has                       %!style            is html-attr;
    has Int()                 $!tab-index        is html-attr;
    has Str()                 %!title            is html-attr;
    has YesNo()               $!translate        is html-attr;
    has VirtualKeyboardPolicy $!virtual-keyboard-policy is html-attr;

    submethod TWEAK(*%pars, :$translate where { !.defined || $_ ~~ Bool|YesNo }) {
        if $translate.defined && $translate ~~ Bool {
            $!translate = $translate ?? yes !! no;
        }
        for %pars.keys.grep(*.starts-with: "data-") {
            my $key = .substr: 5;
            %!data{$key} = %pars{"data-{ $key }"}
        }
        nextsame
    }

    method tag-name { $.^shortname.lc }

    method RENDER {
        $.RENDER-ATTRIBUTES;
        "<{ $.tag-name }{ $.RENDER-ATTRIBUTES }>"
    }

    method RENDER-ATTRIBUTES {
        join "", do for @.^attributes.grep(HTMLAttr) -> Attribute $attr {
            my $name = $attr.name.substr: 2;
            my \value = $attr.get_value(self);
            given $attr.type {
                when Positional {
                    do if $attr.get_value: self {
                        " { $name }='{ value.join: " " }'"
                    }
                }
                when Associative {
                    do if $attr.get_value: self {
                        join "", do for value.kv -> $key, $value {
                            " { $name }-{ $key }='{ $value }'"
                        }
                    }
                }
                when YesNo {
                    " { $name }='{ value }'" with value
                }

                when Bool {
                    " { $name }" if value
                }

                default {
                    " { $name }='{ value }'" with value
                }
            }
        }
    }
}

role Node is Leaf {
    has HTML::Components::Tag @.children;

    multi method add-child(HTML::Components::Tag() $comp) {
        @!children.push: $comp;
        $comp
    }

    multi method add-child(&body) {
        self.&body;
        self
    }

    method RENDER {
        [
            callsame,
            @!children.map(*.RENDER).join("\n").indent(4),
            "</{ $.tag-name }>"
        ].join: "\n"
    }
}

sub all-html-attrs($type) { $type.^attributes.grep(HTMLAttr)».name».substr: 2 }

class BASE {...}
class HEAD {...}
class HTML {...}
class BODY {...}
enum _target <_self _blank _parent _top>;
subset Target of Any where { !.defined || $_ ~~ Str|_target };

role OnHTML {
    multi method base(Str :$href!, *%_ where { .keys.none ~~ "target" && .keys.all ~~ BASE.&all-html-attrs.any }) {
        $.add-child: BASE.new: :$href, |%_
    }
    multi method base(Target :$target!, *%_ where { .keys.none ~~ "href" && .keys.all ~~ BASE.&all-html-attrs.any }) {
        $.add-child: BASE.new: :$target, |%_
    }
    multi method base(Str :$href!, Target :$target!, *%_ where { .keys.all ~~ BASE.&all-html-attrs.any }) {
        $.add-child: BASE.new: :$href, :$target, |%_
    }

    multi method head(Str :$href, Target :$target, *%_ where { .keys.all ~~ HEAD.&all-html-attrs.any }) {
        $.add-child: HEAD.new: |(:$href with $href), |(:$target with $target), |%_
    }
    multi method head(&body, Str :$href, Target :$target, *%_ where { .keys.all ~~ HEAD.&all-html-attrs.any }) {
        my $head = $.head: |(:$href with $href), |(:$target with $target), |%_;
        $head.&body;
        $head
    }
    multi method body(|c) {
        self.add-child: BODY.new: |c
    }
}

class BASE does Leaf {
    has URL    $.href   is html-attr;
    has Target $.target is html-attr;
}

enum LinkAs <audio document embed fetch font image object script style track video worker>;
enum LinkCrossOrigin <anonymous use-credentials>;
enum LinkFetchPriority <high low auto>;
class LINK does Leaf {
    has Str                 $.rel            is html-attr;
    has LinkAs()            $.as             is html-attr;
    has LinkCrossOrigin()   $.cross-origin   is html-attr;
    has Bool()              $.disabled       is html-attr is DEPRECATED;
    has LinkFetchPriority() $.fetch-priority is html-attr;
    has URL()               $.href           is html-attr;
    has Str                 $.href-lang      is html-attr;
    has Str()               $.image-sizes    is html-attr;
    has Str()               @.image-src-set  is html-attr;

    submethod TWEAK(:@image-src-set, :$disabled, :$as, |) {
        if @image-src-set {
            die 'image-src-set requires rel="preload" and as="image" (no rel defined).' without $!rel;
            die 'image-src-set requires rel="preload" and as="image" (no as defined).' without $!as;
            die 'image-src-set requires rel="preload" and as="image".' unless $!rel eq "preload" && $!as eq "image";
        }
        with $disabled {
            die 'disabled requires rel="stylesheet" (no rel defined).' without $!rel;
            die 'disabled requires rel="stylesheet"' unless $!rel eq "stylesheet";
        }
    }
}

class TITLE {...}
class META {...}
role OnHead {
    multi method title(*@title, *%_ where { .keys.all ~~ TITLE.&all-html-attrs.any }) {
        my $t = $.add-child: TITLE.new: |%_;
        $t.add-child: $_ for @title.duckmap: -> Text() $_ { $_ };
        $t
    }
    multi method title(&body, *%_ where { .keys.all ~~ TITLE.&all-html-attrs.any }) {
        my $t = $.add-child: TITLE.new: |%_;
        $.title: |body $t;
    }
    method link(
        LinkAs()            :$as,
        LinkCrossOrigin     :$cross-origin,
        Bool()              :$disabled,
        LinkFetchPriority() :$fetch-priority,
        URL()               :$href,
        Str                 :$href-lang,
        Str()               :$image-sizes,
        *%_ where { .keys.all ~~ LINK.&all-html-attrs.any }
    ) {
        $.add-child: LINK.new:
          |(:$as             with $as             ),
          |(:$cross-origin   with $cross-origin   ),
          |(:$disabled       with $disabled       ),
          |(:$fetch-priority with $fetch-priority ),
          |(:$href           with $href           ),
          |(:$href-lang      with $href-lang      ),
          |(:$image-sizes    with $image-sizes    ),
        ;
    }
}
class TITLE does Node {}
class META does Leaf {}
class HEAD {
    has URL @.profile is html-attr is DEPRECATED;
}

class HTML does OnHTML does Node { }

class Ol {...}
class Input {...}

enum InputType <button checkbox color date datetime-local email file hidden upload-image month number password radio range reset search submit tel text time url week>;
role OnBody {
    method ol(|c)    { self.add-child: Ol.new: |c }
    method input(|c) { self.add-child: Input.new: |c }

    multi method input-checkbox(|c) { self.input: |c, type => checkbox }
}

class Li does OnBody does Node {
    multi method new(Str $data, *%_) {
        self.new: [ $data ], |%_
    }
    multi method new(*@data where @data > 0, *%_) {
        self.new: @data, |%_
    }
    multi method new(@data, *%_) {
        my $l = self.new: |%_;
        $l.add-child: $_ for @data;
        $l
    }
}

role OnOl {
    method li(|c) {
        my Li $li .= new: |c;
        self.add-child: $li;
    }
}
class Ol does OnOl does Node {
    multi method new(%data)      { self.new: |%data }
    multi method new(@li, *%_) {
        my Ol $ol .= new: |%_;
        for @li -> $data {
            $ol.li: $data
        }
        $ol
    }
    multi method new(+@li where @li > 0, *%_) {
        Ol.new: @li, |%_
    }
    multi method new(Str $li, *%_) {
        Ol.new: [ $li ], |%_
    }
}

class Input does Leaf { # TODO: add all attributes
    has InputType $.type    is html-attr = text;
    has Str()     $.name    is html-attr;
    has Bool      $.checked is html-attr;
}

class BODY does OnBody does Node {
    has $.alink              is html-attr is DEPRECATED;
    has $.background         is html-attr is DEPRECATED;
    has $.bgcolor            is html-attr is DEPRECATED;
    has $.bottom-margin      is html-attr is DEPRECATED;
    has $.left-margin        is html-attr is DEPRECATED;
    has $.link               is html-attr is DEPRECATED;
    has $.on-after-print     is html-attr;
    has $.on-before-print    is html-attr;
    has $.on-before-load     is html-attr;
    has $.on-blur            is html-attr;
    has $.on-error           is html-attr;
    has $.on-focus           is html-attr;
    has $.on-hash-change     is html-attr;
    has $.on-language-change is html-attr;
    has $.on-load            is html-attr;
    has $.on-message         is html-attr;
    has $.on-offline         is html-attr;
    has $.on-online          is html-attr;
    has $.on-pop-state       is html-attr;
    has $.on-redo            is html-attr;
    has $.on-resize          is html-attr;
    has $.on-storage         is html-attr;
    has $.on-undo            is html-attr;
    has $.on-unload          is html-attr;
    has $.right-margin       is html-attr is DEPRECATED;
    has $.text               is html-attr is DEPRECATED;
    has $.top-margin         is html-attr is DEPRECATED;
    has $.vlink              is html-attr is DEPRECATED;

    multi method new(%data) { self.new: |%data }
    multi method new(*@data where @data > 0, *%_) {
        my $b = self.new: |%_;
        for @data -> \data {
            $b.add-child: data
        }
        $b
    }
}

sub html(&body, *%_ where { .keys.all ~~ HTML.&all-html-attrs.any }) is export {
    my $html = HTML.new: |%_;
    $html.&body;
    $html
}

sub body(&func, *%_ where { .keys.all ~~ BODY.&all-html-attrs.any }) is export {
    my $body = BODY.new: |%_;
    $body.&func;
    $body
}

class SNIPPET does OnOl does OnBody does OnHTML does OnHead does Node {}

sub snippet(&func) is export {
    #do given func SNIPPET.new { .children.head }
    func SNIPPET.new # for now
}

role HTML::Component is HTML::Components {
    method RENDER($) {...}
    method render-root {
        html -> HTML::Components $root { self.RENDER: $root }
    }
    method render {
        snippet(-> HTML::Components $root { self.RENDER: $root }).RENDER
    }
}
