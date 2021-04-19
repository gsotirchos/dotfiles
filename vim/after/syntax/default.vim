"" dark parentheses and member operators
"syntax match myMemberOperator "\( \)\@<!\.\( \)\@!"
"syntax match myMemberOperator "[(){}\[\],;]"

"syntax enable

" bright marks, operators, logicals
syntax match myMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained
syntax match myUrl "http.:\/\/\S*" containedin=.*Comment.* contained
"syntax match myOperator "[-+=?!$%^&*\\|~/:]" contains=TOP
"syntax match myOperator "[<>]*[-=]\+[<>]*" contains=TOP
"syntax match myOperator "\s[<>]\+\s" containedin=NONE

hi! link myMemberOperator MembOperator
hi! link myOperator Operator
hi! link myMark SpecialComment
hi! link myUrl underlined
