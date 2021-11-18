" highlight 'nullptr' and 'nullopt' as types
syntax keyword Statement nullptr
syntax keyword Statement nullopt

" highlight %...Tag()% in comments
syntax region myMark
\   start="\(\".*\)\@<!\(%.*Tag(\)\@<="
\   end="\()%\)\@="
\   containedin=.*Comment.* contained oneline

" darker semicolons
syntax match myMemberOperator ";"
if hlexists("cAnsiFunction")
    syntax clear cAnsiFunction
endif

" highlight 'namespace', 'enum', and 'struct'
syntax match cppNamespace
\   "\(^\(.*;\+\)*[ \n]*\(namespace\|enum\|struct\)[ \n]\+\)\@<=\h\w*"

hi! link myMark           SpecialComment
hi! link myMemberOperator MembOperator
"hi! link cCustomScope     MembOperator
hi! link cCustomDot       Normal
hi! link cCustomPtr       MembOperator
hi! link cFormat          Special
hi! link cOperator        Statement
hi! link cppOperator      Statement
hi! link cppSTLfunction   Function
hi! link cppSTLconstant   Function
hi! link cppSTLnamespace  Function
hi! link cppSTLexception  Function
hi! link cCustomFunc      Function
hi! link cCustomClass     Function
hi! link cCustomClassName Identifier
hi! link cppNamespace     Identifier

" Doxygen
set syntax=cpp.doxygen
hi! link doxygenComment              Comment
hi! link doxygenStart                doxygenComment
hi! link doxygenSkipComment          doxygenComment
hi! link doxygenContinueComment      doxygenComment
hi! link doxygenBody                 Normal
hi! link doxygenSpecialIdent         doxygenBody
hi! link doxygenSpecialMultilineDesc doxygenBody
hi! link doxygenBrief                doxygenBody
hi! link doxygenHtmlVar              doxygenBody
hi! link doxygenParamDirection       doxygenBody
hi! link doxygenParamName            SpecialComment
hi! link doxygenSpecialSectionDesc   doxygenParamName
hi! link doxygenBriefLine            doxygenParamName
hi! link doxygenHtmlCh               doxygenParamName
hi! link doxygenHtmlCmd              doxygenParamName
hi! link doxygenFormula              doxygenParamName
hi! link doxygenFormulaSpecial       doxygenFormula
hi! link doxygenFormulaKeyword       doxygenFormula
hi! link doxygenSpecial              Comment
hi! link doxygenStartL               doxygenSpecial
hi! link doxygenSmallSpecial         doxygenSpecial
hi! link doxygenBriefWord            doxygenSpecial
hi! link doxygenParam                doxygenSpecial
hi! link doxygenSpecialBoldWord      doxygenSpecial

" vim-easytags
hi! link cTypeTag Error
hi! link cEnumTag Error
hi! link cPreProcTag Error
hi! link cFunctionTag Error
hi! link cMemberTag Error
