syn match texCmdBackslash "\\" containedin=texStatement,texTypeStyle,texNewCmd contained conceal
syn match texStatement "newline" containedin=texStatement contained conceal cchar=⏎
syn match texSpecialChar "\\\\" containedin=texSpecialChar contained conceal cchar=⏎
syn match texSpecialChar "\\{" containedin=texSpecialChar contained conceal cchar={
syn match texSpecialChar "\\}" containedin=texSpecialChar contained conceal cchar=}
syn match texSpecialChar "\\_" containedin=texSpecialChar contained conceal cchar=_
syn match texSectionZone "\\ " containedin=texSectionZone conceal cchar=_


hi! link texCmdBackslash     Dimmed

hi! link texSection          Statement
hi! link texDelimiter        MembOperator
hi! link texRefZone          texBeginEndName

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
