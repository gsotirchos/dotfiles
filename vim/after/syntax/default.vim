" dark parentheses and punctuation
syntax match myDots "[0-9]\@<!\.[0-9]\@!" contains=.*Operator.*
syntax match myDots "::" contains=.*Operator.*
syntax match myParens "[(){}\[\]<>,;]" contains=.*Comment

" bright operators and logicals
syntax match myOperator "[-+=?!$%^&*\\|~]" contains=.*Comment
syntax match myOperator "[<>]*[-=]\+[<>]*" contains=.*Comment
syntax match myOperator "[/*]\@<!/[/*]\@!"  " '/' operator
syntax match myOperator "\s[<>]\+\s"

hi def link myDots     Special
hi def link myParens   Special
hi def link myOperator Operator
