let g:cpp_class_scope_highlight = 1  " for '::'
let g:cpp_member_variable_highlight = 1  " for '->'
let g:cpp_class_decl_highlight = 1
let g:cpp_posix_standard = 1
"let g:cpp_experimental_simple_template_highlight = 1
"let g:cpp_experimental_template_highlight = 1
let g:cpp_concepts_highlight = 1
"let g:cpp_no_function_highlight = 1
"let c_no_curly_error=1

"syntax match cppName "\(^\(.*;\+\)*[ \n]*\S\+[^({][ \n]\+\)\@<=\(\h\w::\)*\h\w*\([ \n]*[({=]\)\@="
syntax match cppNamespace "\(^\(.*;\+\)*[ \n]*\(namespace\|enum\)[ \n]\+\)\@<=\h\w*"
syntax region myMark
\    start="\(\".*\)\@<!\(%.*Tag(\)\@<="
\    end="\()%\)\@="
\    containedin=.*Comment.* contained oneline
syntax match myMemberOperator ";"

hi! link myMark           SpecialComment
hi! link myMemberOperator MembOperator
hi! link cCustomScope     MembOperator
hi! link cCustomDot       MembOperator
hi! link cCustomPtr       MembOperator
hi! link cFormat          Special
hi! link cOperator        Statement
hi! link cppOperator      Statement
hi! link cppSTLFunction   Function
hi! link cppSTLconstant   Function
hi! link cppSTLnamespace  Function
hi! link cppSTLException  Function
hi! link cppSTLType       Function
hi! link cCustomFunc      Function
hi! link cCustomClass     Function
hi! link cCustomClassName Identifier
hi! link cppNamespace     Identifier
"hi! link cppName          Function
