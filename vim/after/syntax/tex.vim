"syntax match texCmdBackslash "\\" containedin=.*texCmd.* contained


"hi! clear texItalStyle
"hi! clear texBoldStyle

hi! link texCmdBackslash     Comment

hi! link texPartArgTitle     Normal
hi! link texPartConcArgTitle SpecialComment
hi! link texInputFile        PreProc
hi! link texBeginEnd         texStatement
hi! link texBeginEndName     Identifier
hi! link texSpecialChar      Special
hi! link texOptEqual         Normal
hi! link texOpt              Function

hi! link texCmdLigature      texCmd
hi! link texCmdStyle         OtherType
hi! link texCmdStyleBold     texCmdStyle
hi! link texCmdStyleItal     texCmdStyle
hi! link texMathCmdStyle     texCmdStyle
hi! link texMathCmdStyleBold texCmdStyleBold
hi! link texMathCmdStyleItal texCmdStyleItal

hi! link texRefZone          OtherType
hi! link texMathMatcher      Normal
hi! link texMathZoneX        texDocZone
hi! link texMathZoneX        texDocZone
hi! link texMathZone         Normal
hi! link texMathDelim        Delimiter
hi! link texMathDelimMod     texCmdStyle
hi! link texEnvArgName       Identifier
hi! link texMathEnvArgName   texEnvArgName
hi! link texDelim            MembOperator
hi! link texMathSuperSub     texDelim
