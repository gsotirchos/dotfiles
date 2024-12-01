syntax match vimComment "\".*" containedin=vim.*Comment


"hi! clear CursorLine
"hi! clear CursorColumn
hi! link vim9Comment     Normal
hi! link vimParenSep     Normal
hi! link vimBracket      Normal
hi! link vimMapMod       Normal
hi! link vimSetSep       Normal
hi! link vimSetRegion    vimSet
hi! link vimSep          MyOperator
hi! link vimCmdSep       vimSep
hi! link vimMapModKey    PreProc
hi! link vimFunction     Function
hi! link vimUserFunc     vimFunction
hi! link vimGroup        Function
hi! link vimGroupSpecial Function
hi! link vimHiGroup      vimGroup
hi! link vimGroupName    vimVar
hi! link vimOption       vimVar
hi! link vimOper         Operator
hi! link vimContinue     Comment

" ALE
"hi! link ALEErrorLine   Normal
"hi! link ALEWarningLine Normal
