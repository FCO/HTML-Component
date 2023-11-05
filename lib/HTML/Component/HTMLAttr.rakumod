unit role HTML::Component::HTMLAttr;

multi trait_mod:<is>(Attribute $attr, :$html-attr!) is export {
    trait_mod:<is>($attr, :built);
    $attr does HTML::Component::HTMLAttr
}
