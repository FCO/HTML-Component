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
class HTML::Components {}

class Text is Str is HTML::Components {
    method COERCE(Str $value) { ::?CLASS.new: :$value }

    method RENDER { $.Str }
}

role Leaf is HTML::Components {
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

                default {
                    " { $name }='{ value }'" with value
                }
            }
        }
    }
}

role Node is Leaf {
    has HTML::Components @.children;

    method add-child(HTML::Components $comp) {
        @!children.push: $comp;
        $comp
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
enum _target <_self _blank _parent _top>;
subset Target of Any where { !.defined || $_ ~~ Str|_target };

role OnHTML does Node {
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
role OnHead does Node {
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
class HEAD does OnHead {
    has URL @.profile is html-attr is DEPRECATED;
}

class HTML does OnHTML {
    
}

sub html(&body, *%_ where { .keys.all ~~ HTML.&all-html-attrs.any }) is export {
    my $html = HTML.new: |%_;
    $html.&body;
    $html
}
