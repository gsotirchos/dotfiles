set syntax=cpp.doxygen

let g:cpp_class_scope_highlight = 1  " for '::'
let g:cpp_member_variable_highlight = 1  " for '->' and '.'
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
"let g:cpp_experimental_simple_template_highlight = 1
"let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
"let g:cpp_no_function_highlight = 1
"let c_no_curly_error=1

"syntax region myNormal keepend extend
"\   start="("hs=e+1
"\   end=")"he=s-1
"\   contains=TOP,.*Func.*,.*Class.*,.*STL.*
syntax match cppNamespace
\   "\(^\(.*;\+\)*[ \n]*\(namespace\|enum\|struct\)[ \n]\+\)\@<=\h\w*"
syntax region myMark
\   start="\(\".*\)\@<!\(%.*Tag(\)\@<="
\   end="\()%\)\@="
\   containedin=.*Comment.* contained oneline
syntax match myMemberOperator ";"
if hlexists("cAnsiFunction")
    syntax clear cAnsiFunction
endif

syntax keyword Statement nullptr
syntax keyword Statement nullopt

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
