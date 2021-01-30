syntax match myParens "[(){}\[\]<>,;]" contains=.*Comment  " parentheses
syntax match myOperator "[-+=?!$%^&*\\|~]" contains=.*Comment  " operators
syntax match myOperator "[/*]\@<!/[/*]\@!"  " brighter '/' operator
syntax match myOperator "->\|<-\|<=\|>="  " brighter logicals
syntax match myOperator "\s\+[<>]\s\+"  " brighter logicals

hi def link myParens   Special
hi def link myOperator Operator
