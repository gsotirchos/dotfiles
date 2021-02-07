" dark parentheses and member operators
syntax match myParens "[(){}\[\]<>,;]" contains=.*Comment.*
syntax match myMemberOperator "[0-9]\@<!\.[0-9]\@!" contains=.*Operator.*

" bright operators and logicals
syntax match myOperator "[-+=?!$%^&*\\|~]" contains=.*Comment.*
syntax match myOperator "[<>]*[-=]\+[<>]*" contains=.*Comment.*
syntax match myOperator "[/*]\@<!/[/*]\@!"  " '/' operator
syntax match myOperator "\s[<>]\+\s"
syntax region Mark start='%' end='%' containedin=.*Comment.* contained oneline

hi link myParens         MembOperator
hi link myMemberOperator MembOperator
hi link myOperator       Operator
hi link Mark             NonText
