unit role OnHTML;
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

