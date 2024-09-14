" comment marks
syntax match Todo "TODO" containedin=.*Comment.*,pythonString contained
syntax match Done "DONE\(\W.*\)\@=" containedin=.*Comment.* contained
syntax match myMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained
syntax match myUrl "http.:\/\/\S*" containedin=.*Comment.* contained

" highlight %Tag(...)% in comments
syntax region myTagMark
\   start="\(\".*\)\@<!\(% *Tag *(\)\@<="
\   end="\() *%\)\@="
\   containedin=.*Comment.* contained oneline

" parentheses and member operators
syntax match myParens "[(){}\[\]<>,;]" containedin=NONE
syntax match MembOperator "[,;]" containedin=NONE
"syntax match MembOperator "\(\w\|[\])][ \n]*\)\@<=\(\(::\)\|\(->\)\|\(\.\)\)\([ \n]*\h\)\@=" containedin=NONE
syntax match MembOperator "\(\(::\)\|\(->\)\|\(\.\)\)\([ \n]*\h\)\@=" containedin=NONE

" assignemnt and logical operators
syntax match myEquals "=" containedIn=None
syntax match myOperator "->" contains=TOP
syntax match myOperator "[-+*/^?$%&|\\!~:]\+" contains=TOP
syntax match myOperator "\(\S\)\@<![<>!~:]\+[=]\=\(\S\)\@!"
syntax match myOperator "\(\S\)\@<!\(\(==\)\|\(->\)\)\(\S\)\@!"


hi! link myMark     SpecialComment
hi! link myTagMark  SpecialComment
hi! link myUrl      Underlined
hi! link myParens   Comment
hi! link myEquals   Statement
hi! link myOperator OtherType
