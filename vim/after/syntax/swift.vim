"syntax match bracketComma "," containedin=.*Wrapper.*

hi! link swiftAttributes  Statement
hi! link swiftImports     Statement
hi! link swiftTypeWrapper Delimiter
hi! link swiftType        otherType
"hi! link bracketComma     MembOperator
hi! link swiftInterpolatedWrapper swiftString
hi! link swiftTypeDeclaration     Normal
