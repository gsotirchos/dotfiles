" dark parentheses and punctuation
syntax match myDots "[0-9]\@<!\.[0-9]\@!"  " darker dots
syntax match myDots "::"  " darker dots
syntax match myParens "[(){}\[\]<>,;]" contains=.*Comment  " parentheses

" bright operators and logicals
syntax match myOperator "[-+=?!$%^&*\\|~]" contains=.*Comment
syntax match myOperator "[<>]*[-=]\+[<>]*" contains=.*Comment
syntax match myOperator "[/*]\@<!/[/*]\@!"  " '/' operator
syntax match myOperator "\s[<>]\+\s"

hi def link myDots     Special
hi def link myParens   Special
hi def link myOperator Operator
