" dark parentheses and member operators
syntax match myParens "[(){}\[\]<>,;]" contains=.*Comment.*
syntax match myMemberOperator "\." containedin=NONE contains=TOP

" bright operators and logicals
syntax match myOperator "\s[<>]\+\s" containedin=NONE
syntax match myOperator "[<>]*[-=]\+[<>]*" containedin=NONE contains=TOP
syntax match myOperator "[-+=?!$%^&*\\|~/:]" containedin=NONE contains=TOP

hi link myParens MembOperator
hi link myMemberOperator MembOperator
hi link myOperator Operator
hi link Mark SpecialComment
