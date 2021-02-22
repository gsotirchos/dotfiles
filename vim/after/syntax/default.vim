" dark parentheses and member operators
syntax match myParens "[(){}\[\],;]" contains=.*Comment.*,.*Operator.*
syntax match myMemberOperator "\." containedin=NONE contains=TOP

" bright operators and logicals
"syntax match myOperator "[-+=?!$%^&*\\|~/:]" contains=TOP
"syntax match myOperator "[<>]*[-=]\+[<>]*" contains=TOP
syntax match myOperator "\s[<>]\+\s" containedin=NONE
syntax match myMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained

hi link myParens MembOperator
hi link myMemberOperator MembOperator
hi link myOperator Operator
hi link myMark SpecialComment
