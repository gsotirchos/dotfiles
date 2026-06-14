syn clear bashSpecialVariables
syn clear shArrayRegion
" syn clear shSpecialDQ

hi! link shFunctionTag  Function
hi! link shDerefSimple  shDerefVar
hi! link shDerefDelim   shDoubleQuote
hi! link shQuote        shDoubleQuote
hi! link shEscape       shSpecial
hi! link shOption       OtherType
hi! link shOperator     Function
hi! link shDerefVar     OtherType
hi! link shTestOpr      shOperator
hi! link shVarAssign    Statement
"hi! link shTestPattern  Normal
hi! link shArithRegion  Normal
hi! link shParen        Normal
hi! link shColon        Normal
hi! link shEcho         Normal
hi! link shCommandSub   Normal
hi! link shCaseStart    Normal
hi! link shSemicolon    MembOperator
hi! link shCmdSubRegion Type
