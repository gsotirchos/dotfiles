" highlight 'nullptr' and 'nullopt' as types
syntax keyword Statement nullptr
syntax keyword Statement nullopt

" highlight %...Tag()% in comments
syntax region myMark
\   start="\(\".*\)\@<!\(%.*Tag(\)\@<="
\   end="\()%\)\@="
\   containedin=.*Comment.* contained oneline

" darker semicolons
syntax match myMembOperator ";"
if hlexists("cAnsiFunction")
    syntax clear cAnsiFunction
endif

" highlight 'namespace', 'enum', and 'struct'
syntax match cppNamespace
\   "\(^\(.*;\+\)*[ \n]*\(\(using \)\=namespace\|enum\|struct\|class\)[ \n]\+\)\@<=\h\w*"

hi! link myMark           SpecialComment
hi! link myMembOperator   MembOperator
hi! link cCustomScope     myMembOperator
hi! link cCustomDot       myMembOperator
hi! link cCustomPtr       myMembOperator
hi! link cFormat          Special
hi! link cOperator        Statement
hi! link cppOperator      cOpertor
hi! link cCustomFunc      Function
hi! link cppSTLfunction   cCustomFunc
hi! link cppSTLconstant   cCustomFunc
hi! link cppSTLnamespace  cCustomFunc
hi! link cppSTLexception  cCustomFunc
hi! link cCustomClass     Function
hi! link cCustomClassName Identifier
hi! link cppNamespace     cCustomClassName

" vim-easytags
hi! link cTypeTag     cCustomClassName
hi! link cEnumTag     cCustomClass
hi! link cPreProcTag  Error
hi! link cFunctionTag cCustomFunc
hi! link cMemberTag   cCustomClass

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

