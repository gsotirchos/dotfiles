syntax match myMemberOperator "::" contains=.*Operator.*
syntax match myMemberOperator "\([a-zA-Z_][a-zA-Z0-9_]*\)\@<=->\([a-zA-Z_]\)\@=" containedin=myOperator

hi! link cFormat Type
hi! link cSpecial Type
