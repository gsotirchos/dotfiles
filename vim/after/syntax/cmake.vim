"syntax match Type "[A-Z_]\+" containedin=cmakeArguments contains=NONE
"syntax match Number "[0-9.]\+" containedin=cmakeArguments contains=NONE
"syntax match Comment "[()\[\]]" containedin=cmakeArguments contains=TOP

hi! link cmakeRegistry Normal
hi! link cmakeVariable Function
hi! link cmakeVariableValue cmakeVariable
hi! link cmakeEnvironment Function
hi! link cmakeGeneratorExpressions CmakeKWstring
hi! link cmakeCommand Statement
hi! link cmakeCommandConditional Statement
hi! link cmakeCommandRepeat Statement
