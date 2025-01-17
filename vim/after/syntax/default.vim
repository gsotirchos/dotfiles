" comment marks
syntax match Todo "TODO" containedin=.*Comment.*,pythonString contained display
syntax match Done "DONE\(\W.*\)\@=" containedin=.*Comment.* contained display
syntax match myMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained display
syntax match myUrl "http.:\/\/\S*" containedin=.*Comment.* contained display

" highlight %Tag(...)% in comments
syntax region myTagMark
\   start="\(\".*\)\@<!\(% *Tag *(\)\@<="
\   end="\() *%\)\@="
\   containedin=.*Comment.* contained oneline

" assignemnt and logical operators
syntax match myEquals "\(\W\|\_s\)\@<==\(\S\)\@!" containedin=NONE display
syntax match myOperator "[-+*/^?$%&|\\!~:]\+" contains=TOP display
syntax match myOperator "\(\S\)\@<![<>!~:]\+[=]\=\(\S\)\@!" display
syntax match myOperator "\(\S\)\@<!\(\(==\)\|\(->\)\)\(\S\)\@!" display

" parentheses and member operators
syntax match myParens "[(){}\[\]<>,;]" containedin=NONE display
syntax match MembOperator "[,;]" containedin=NONE display
syntax match MembOperator "\(\(::\)\|\(->\)\|\(\.\)\)\(\S\)\@=" containedin=NONE display  " also \(\w\|[\])]\_s*\)\@<=


hi! link myMark     SpecialComment
hi! link myTagMark  SpecialComment
hi! link myUrl      Underlined
hi! link myParens   Comment
hi! link myEquals   Statement
hi! link myOperator OtherType
