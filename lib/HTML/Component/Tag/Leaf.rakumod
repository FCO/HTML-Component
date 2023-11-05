use HTML::Component::HTMLAttr;
use HTML::Component::Enums;
use HTML::Component::Tag;
unit role HTML::Component::Tag::Leaf does HTML::Component::Tag;

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

method HTML {
    $.RENDER-ATTRIBUTES;
    "<{ $.tag-name }{ $.RENDER-ATTRIBUTES }>"
}

method RENDER-ATTRIBUTES {
    join "", do for @.^attributes.grep(HTML::Component::HTMLAttr) -> Attribute $attr {
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
