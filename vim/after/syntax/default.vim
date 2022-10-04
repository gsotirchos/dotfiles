" dark parentheses and member operators
"syntax match myMembOperator "\( \)\@<!\.\( \)\@!"
"syntax match myMembOperator "[(){}\[\],;]"

" bright marks, operators, logicals
"syntax match myOperator "[-+=?!$%^&*\\|~/:]" contains=TOP
"syntax match myOperator "[<>]*[-=]\+[<>]*" contains=TOP
"syntax match myOperator "\s[<>]\+\s" containedin=NONE
syntax match Done "DONE\(\W.*\)\@=" containedin=.*Comment.* contained
syntax match myMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained
syntax match myUrl "http.:\/\/\S*" containedin=.*Comment.* contained

"hi! link myMembOperator MembOperator
"hi! link myOperator Operator
hi! link myMark SpecialComment
hi! link myUrl underlined
