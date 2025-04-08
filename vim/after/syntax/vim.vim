syn match vimComment "\".*" containedin=vim.*Comment
syn match Error "\\@\d*[<>]\=!\==\="  " not working
syn match vimOper "|" contained containedin=vimAugroup


"hi! clear CursorLine
"hi! clear CursorColumn
hi! link vim9Comment      Normal
hi! link vimSep           Info
hi! link vimParenSep      vimSep
hi! link vimSetSep        vimSep
hi! link vimBracket       vimSep
hi! link vimSetRegion     vimSet
hi! link vimCmdSep        vimSep
hi! link vimMapModKey     PreProc
hi! link vimMapMod        vimMapModKey
hi! link vimFunction      Function
hi! link vimUserFunc      vimFunction
hi! link vimGroup         Identifier
hi! link vimGroupSpecial  vimGroup
hi! link vimEnvVar        Function
hi! link vimVar           Normal
hi! link vimGroupName     vimVar
hi! link vimOption        vimVar
hi! link vimOptionVarName vimVar
hi! link vimFTOption      PreProc
hi! link vimOper          MyOperator
hi! link vimContinue      Info
hi! link vimAutoGroupTag  Identifier
hi! link vimHiBang        vimOper
hi! link vimHiAttrib      Constant
hi! link vimHiGroup       vimGroup
hi! link vimHiTerm        Function
