multi sub trait_mod:<is>(Parameter $p, :$no-label!) is export {
  $p does role :: { method no-label { ?$no-label } }
}

multi sub trait_mod:<is>(Parameter $p, Str :$label!) is export {
  $p does role :: { method label { $label } }
}
