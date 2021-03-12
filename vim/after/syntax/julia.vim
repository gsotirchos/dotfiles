syntax match myMemberOperator "\." containedin=ALL contains=TOP

hi! link myMemberOperator  MembOperator
hi! link juliaParDelim     MembOperator
hi! link juliaComma        MembOperator
hi! link juliaTypeOperator MembOperator
hi! link juliaOperator     Delimiter
hi! link juliaOperatorHL   Delimiter
hi! link juliaFunctionCall Function
