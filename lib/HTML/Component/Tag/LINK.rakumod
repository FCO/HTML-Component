use HTML::Component::Enums;
use HTML::Component::Tag::Leaf;
use HTML::Component::HTMLAttr;

unit class HTML::Component::Tag::LINK does HTML::Component::Tag::Leaf;

has Str                 $.rel            is html-attr;
has LinkAs()            $.as             is html-attr;
has LinkCrossOrigin()   $.cross-origin   is html-attr;
# has Bool()              $.disabled       is html-attr is DEPRECATED;
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
