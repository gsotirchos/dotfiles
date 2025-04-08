"syntax match texCmdBackslash "\\" containedin=.*tex.*Cmd.* contained display cchar=\

"hi! link texCmdBackslash     Info

hi! link texDelim            MembOperator
hi! link texBeginEnd         texStatement
hi! link texBeginEndName     Identifier
hi! link texOpt              Function
hi! link texOptEqual         Normal
hi! link texPartArgTitle     Normal
hi! link texPartConcArgTitle SpecialComment
hi! link texTitleArg         SpecialComment
hi! link texInputFile        PreProc
hi! link texSpecialChar      Special
hi! link texEnvArgName       Identifier
hi! link texRefZone          OtherType
hi! link texHrefArgTextC     underlined

hi! link texCmdLigature      texCmd
hi! link texCmdStyle         Type
hi! link texCmdSize          texCmdStyle
hi! link texCmdStyleBold     texCmdStyle
hi! link texCmdStyleItal     texCmdStyle
hi! link texMathCmdStyle     texCmdStyle
hi! link texMathCmdSize      texCmdSize
hi! link texMathCmdStyleBold texCmdStyleBold
hi! link texMathCmdStyleItal texCmdStyleItal

hi! link texMathMatcher      Normal
hi! link texMathZone         Normal
hi! link texMathZoneX        texDocZone
hi! link texMathZoneX        texDocZone
hi! link texMathOper         OtherType
hi! link texMathDelim        texMathOper
hi! link texMathDelimMod     texCmdStyle
hi! link texMathEnvArgName   texEnvArgName
