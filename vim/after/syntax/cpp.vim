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
hi! link cFormat          Special
hi! link cOperator        Statement
hi! link cCustomClassName Identifier
hi! link cCustomClass     Function
hi! link cCustomFunc      Function
hi! link cCustomScope     Normal
hi! link cCustomDot       cCustomScope
hi! link cCustomPtr       cCustomScope
hi! link cppOperator      cOpertor
hi! link cppNamespace     cCustomClassName
hi! link cppSTLfunction   cCustomFunc
hi! link cppSTLconstant   cCustomFunc
hi! link cppSTLexception  cCustomFunc
hi! link cppSTLnamespace  cppNamespace

" vim-easytags
hi! link cPreProcTag  Error
hi! link cTypeTag     cCustomClassName
hi! link cEnumTag     cCustomClass
hi! link cMemberTag   cCustomClass
hi! link cFunctionTag cCustomFunc

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

