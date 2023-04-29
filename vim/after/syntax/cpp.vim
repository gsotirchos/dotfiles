" operators, logicals, parentheses and member operators
syntax match myParens "[(){}\[\]<>,;]" containedin=NONE
syntax match MembOperator "[,;]" containedin=NONE
syntax match MembOperator "\(\S\)\@<=\(\(::\)\|\(->\)\|\(\.\)\)\(\S\)\@=" containedin=NONE
syntax match myOperator "->" contains=TOP
syntax match myOperator "[-+*/^?$%&|\\!~:]\+" contains=TOP
syntax match myOperator "\(\S\)\@<![<>!~:]\+[=]\=\(\S\)\@!"
syntax match myOperator "\(\S\)\@<!\(\(==\)\|\(->\)\)\(\S\)\@!"

" highlight %Tag(...)% in comments
syntax region myTagMark
\   start="\(\".*\)\@<!\(% *Tag *(\)\@<="
\   end="\() *%\)\@="
\   containedin=.*Comment.* contained oneline

" darker semicolons
"syntax match cTerminator ";"

" highlight 'namespace', 'enum', and 'struct' names
syntax match cppNamespace "\(^\(.*;\+\)*[ \n]*\(using \)\=namespace[ \n]\+\)\@<=\h\w*"

hi! link cCustom Function

hi! link myParens Comment
hi! link myOperator OtherType
hi! link myTagMark       SpecialComment
"hi! link myScopeOperator Normal
hi! link cTerminator     MembOperator
hi! link cTypedef        Typedef
hi! link cOperator       Statement
hi! link cMember         Function
hi! link cEnum           cMember
hi! link cppAttribute    Comment
hi! link cppNamespace    Identifier
hi! link cppOperator     cOperator
hi! link cppSTLvariable  cMember
hi! link cppSTLnamespace cppNamespace
hi! link cppSTLconstant  cppSTLvariable
hi! link cppSTLiterator  cppSTLvariable
hi! link cppSTLexception cppSTLvariable

" vim-easytags
hi! link cPreProcTag  Constant
hi! link cTypeTag     cppNamespace
"hi! link cFunctionTag cFunction
hi! link cMemberTag   cMember
hi! link cEnumTag     cMemberTag

" Doxygen
set syntax=cpp.doxygen
hi! link doxygenComment                Comment
hi! link doxygenStart                  doxygenComment
hi! link doxygenSkipComment            doxygenComment
hi! link doxygenContinueComment        doxygenComment
hi! link doxygenBody                   DocComment
hi! link doxygenSpecialIdent           doxygenBody
hi! link doxygenSpecialMultilineDesc   doxygenBody
hi! link doxygenSpecialTypeOnelineDesc doxygenBody
hi! link doxygenBrief                  doxygenBody
hi! link doxygenBriefLine              doxygenBody
hi! link doxygenHtmlVar                doxygenBody
hi! link doxygenParamDirection         doxygenBody
hi! link doxygenParamName              SpecialComment
hi! link doxygenSpecialSectionDesc     doxygenParamName
hi! link doxygenHtmlCh                 doxygenParamName
hi! link doxygenHtmlCmd                doxygenParamName
hi! link doxygenFormula                doxygenParamName
hi! link doxygenFormulaSpecial         doxygenFormula
hi! link doxygenFormulaKeyword         doxygenFormula
hi! link doxygenSpecial                Comment
hi! link doxygenBOther                 doxygenSpecial
hi! link doxygenStartL                 doxygenSpecial
hi! link doxygenSmallSpecial           doxygenSpecial
hi! link doxygenBriefWord              doxygenSpecial
hi! link doxygenParam                  doxygenSpecial
hi! link doxygenParamDirection         doxygenSpecial
hi! link doxygenSpecialBoldWord        doxygenSpecial

"augroup cpp_syntax
"    autocmd BufWinEnter *.cpp syntax match myScopeOperator "::" containedin=.*FunctionTag.* contained
"    autocmd BufWinEnter *.cpp syntax keyword cppSTLconstant nullptr
"augroup END
