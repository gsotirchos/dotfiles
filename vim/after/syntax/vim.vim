syn match vimComment "\".*" containedin=vim.*Comment
syn match Error "\\@\d*[<>]\=!\==\="  " not working
syn match vimOper "|" containedin=vimAugroup,vimCmdSep contained
syn match vimOper "=" containedin=vimSynContains contained
"syn match vimIsCommand ".*" containedin=vimIsCommand contained


"hi! clear                    CursorLine
"hi! clear                    CursorColumn
hi! link vim9Comment         Normal
hi! link vimSep              Dimmed
hi! link vimSetSep           vimSep
hi! link vimCmdSep           vimSep
hi! link vimParenSep         vimSep
hi! link vimSetRegion        vimSet
hi! link vimBracket          vimSep
hi! link vimContinue         vimSep
hi! link vimMapModKey        PreProc
hi! link vimMapMod           vimMapModKey
hi! link vimFunction         Function
hi! link vimUserFunc         vimFunction
hi! link vimHiTerm           vimFunction
hi! link vimSynMtchOpt       PreProc
hi! link vimSynContains      vimSynMtchOpt
hi! link vimUserCmdAttrKey   vimSynMtchOpt
hi! link vimUserCmdAttr      MyOperator
hi! link vimUserCmdAttrNargs String
hi! link vimSynRegOpt        vimSynContains
hi! link vimSynRegPat        Normal
hi! link vimSynPatRange      String
hi! link vimPatSep           MyOperator
hi! link vimPatSepR          Special
hi! link vimGroup            Identifier
hi! link vimGroupName        vimGroup
hi! link vimAutoCmdGroup     vimGroup
hi! link vimAutoGroupTag     vimGroup
hi! link vimGroupSpecial     Constant
hi! link vimAuGroupEnd       Type
hi! link vimEnvVar           Constant
hi! link vimVar              Normal
hi! link vimOption           vimVar
hi! link vimOptionVarName    vimVar
hi! link vimSetEqual         String
hi! link vimOper             MyOperator
hi! link vimHiBang           vimOper
hi! link vimHiAttrib         Constant
hi! link vimHiGroup          vimGroup
