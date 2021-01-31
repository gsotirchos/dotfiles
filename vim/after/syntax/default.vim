" dark parentheses and member operators
syntax match myParens "[(){}\[\]<>,;]" contains=.*Comment.*
syntax match myMemberOperator "[0-9]\@<!\.[0-9]\@!" contains=.*Operator.*

" bright operators and logicals
syntax match myOperator "[-+=?!$%^&*\\|~]" contains=.*Comment.*
syntax match myOperator "[<>]*[-=]\+[<>]*" contains=.*Comment.*
syntax match myOperator "[/*]\@<!/[/*]\@!"  " '/' operator
syntax match myOperator "\s[<>]\+\s"

hi def link myParens         Comment
hi def link myMemberOperator Comment
hi def link myOperator       Operator
