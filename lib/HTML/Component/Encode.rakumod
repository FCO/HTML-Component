sub html-encode($str) is export {
    $str.trans:
        /\&/ => '&amp;',
        /\</ => '&lt;',
        /\>/ => '&gt;',
        /\"/ => '&quot;',
        /\'/ => '&apos;',
        /<[\xA0..\xD8FF \xE000..\xFFFD]>{}/
            => { '&#' ~ $/.ord ~ ';' },
}

