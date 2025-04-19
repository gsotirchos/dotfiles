" comment marks
syntax match Todo "TODO" containedin=.*Comment.*,pythonString contained display
syntax match Done "DONE" containedin=.*Comment.* contained display
syntax match MyNote "NOTE" containedin=.*Comment.* contained display
"syntax match MyNote "\(NOTE:\s\)\@<=.*" containedin=.*Comment.* contained display
syntax match MyUrl "http.:\/\/\S*" containedin=.*Comment.* contained display

" highlight %Tag(...)% in comments
syntax region MyTagMark
    \ start="\(\".*\)\@<!\(% *Tag *(\)\@<="
    \ end="\() *%\)\@="
    \ containedin=.*Comment.* contained oneline

" assignemnt and logical operators
syntax match MyParens "[(){}\[\]<>,;]" containedin=NONE display
syntax match MyEquals "\(\W\|\_s\)\@<==\(\S\)\@!" containedin=NONE display
syntax match MyOperator "[-+*/^?$%&|\\!~:]\+" contains=TOP display
syntax match MyOperator "\(\S\)\@<![<>!~:]\+[=]\=\(\S\)\@!" display
syntax match MyOperator "\(\S\)\@<!\(\(==\)\|\(->\)\)\(\S\)\@!" display

" member operators
syntax match MembOperator "[,;]" containedin=NONE display
syntax match MembOperator "\(\(::\)\|\(->\)\|\(\.\)\)\(\S\)\@=" containedin=NONE display  " also \(\w\|[\])]\_s*\)\@<=
