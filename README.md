# NAME

HTML::Components - is the begining of components (WiP)

# SYNOPSIS

```raku
use HTML::Components;

class Todo does HTML::Component {
    has Str  $.description is required;
    has Bool $.done = False;

    multi method new(Str $description, *%_) { self.new: :$description, |%_ }

    method RENDER(HTML::Components::Tag $_) {
        .li: {
            .input-checkbox: :name<done>, :checked($!done);
            .add-child: $!description;
        }
    }
}

say Todo.new("testing...", :done).render
```

# DESCRIPTION

HTML::Components is comming...

# AUTHOR

Fernando Corrêa de Oliveira <fernandocorrea@gmail.com>

# COPYRIGHT AND LICENSE

Copyright 2023 Fernando Corrêa de Oliveira

This library is free software; you can redistribute it and/or modify it under the Artistic License 2.0.
