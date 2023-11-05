use HTML::Component::Tag::Node;
use HTML::Component::Tag::Text;

# TODO: Add type again (it should be HTML::Component::Tag)
sub add-methods-to-tag(Mu $tag, +@sub-tags) is export {
  for @sub-tags -> Str $sub-type-name {
    $tag.^add_method: $sub-type-name, my method (|c) {
      my $sub-tag-file = "HTML::Component::Tag::{ uc $sub-type-name.split("-").first }";
      my $sub-tag-class = "HTML::Component::Tag::{ uc $sub-type-name }";
      require ::($sub-tag-file);
      my $sub-tag = ::($sub-tag-class);
      my $new = $sub-tag.new: |c;
      self.add-child: $new
    }
  }
}

role HTML::Component::PositionalsToValues[*@keys where *.elems > 0] {
  multi method new(*@values where *.elems > 0, *%_) {
    self.new: |%_, |%( @keys Z[=>] @values )
  }
}

role HTML::Component::PositionalAsChild {
  multi method new(HTML::Component::Tag::Text() $value, *%_) {
    my $new = self.new: |%_;
    $new.add-child: $value;
    $new
  }
}
