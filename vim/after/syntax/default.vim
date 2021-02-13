" dark parentheses and member operators
syntax match myParens "[(){}\[\]<>,;]" contains=TOP
syntax match myMemberOperator "\." containedin=NONE contains=TOP

" bright operators and logicals
syntax match myOperator "\s[<>]\+\s" containedin=NONE
syntax match myOperator "[<>]*[-=]\+[<>]*" contains=TOP
syntax match myOperator "[-+=?!$%^&*\\|~/:]" contains=TOP

hi link myParens MembOperator
hi link myMemberOperator MembOperator
hi link myOperator Operator
hi link Mark SpecialComment
