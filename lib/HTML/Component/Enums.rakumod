enum AutoCapitalize        <off none on sentences words characters>;
enum Dir                   <ltr rtl dir-auto>;                     # TODO: fix enum
enum YesNo                 <no yes>;
enum VirtualKeyboardPolicy <policy-auto manual>;                   # TODO: fix enum
enum _target               <_self _blank _parent _top>;
enum LinkAs                <audio document embed fetch font image object script style track video worker>;
enum LinkCrossOrigin       <anonymous use-credentials>;
enum LinkFetchPriority     <high low auto>;
enum InputType             <button checkbox color date datetime-local email file hidden upload-image month number password radio range reset search submit tel text time url week>;
enum HTTPEquiv             <content-security-policy content-type default-style x-ua-compatible refresh>;

subset Target of Any where { !.defined || $_ ~~ Str|_target };
subset URL of Str;
