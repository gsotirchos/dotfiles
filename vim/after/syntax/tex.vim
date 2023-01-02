"syntax match texCmdBackslash "\\" containedin=.*texCmd.* contained


"hi! clear texItalStyle
"hi! clear texBoldStyle

hi! link texCmdBackslash     Comment

hi! link texPartArgTitle     Normal
hi! link texPartConcArgTitle SpecialComment
hi! link texInputFile        PreProc
hi! link texBeginEnd         texStatement
hi! link texBeginEndName     Identifier
hi! link TexSpecialChar      Special

hi! link texCmdStyle         Type
hi! link texCmdStyleBold     texCmdStyle
hi! link texCmdStyleItal     texCmdStyle
hi! link texMathCmdStyle     texCmdStyle
hi! link texMathCmdStyleBold texCmdStyleBold
hi! link texMathCmdStyleItal texCmdStyleItal

hi! link texRefZone          Type
hi! link texMathMatcher      Normal
hi! link texMathZoneX        texDocZone
hi! link texMathZoneX        texDocZone
hi! link texMathZone         Normal
hi! link texMathDelim        texMathZoneEnv
hi! link texEnvArgName       Identifier
hi! link texMathEnvArgName   texEnvArgName
hi! link texDelim            MembOperator
hi! link texMathSuperSub     texDelim
