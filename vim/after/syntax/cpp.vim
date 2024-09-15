" highlight 'namespace', 'enum', and 'struct' names
syntax match cppNamespace "\(^\(.*;\+\)*[ \n]*\(using \)\=namespace[ \n]\+\)\@<=\h\w*"

" better preproc coloring
syntax match cPreProcVar "\(\s*#\w*\s\)\@<=\S*" containedIn=.*PreProc.* contained

" syntax keyword cppSTLconstant nullptr

"hi! link myScopeOperator Normal
hi! link cTerminator     MembOperator
hi! link cTypedef        Typedef
"hi! link cDefine         Constant
hi! link cPreProcVar     Constant
"hi! link cOperator       Statement
hi! link cMember         Function
hi! link cCustom         Function
"hi! link cppCast         Function
hi! link cEnum           cMember
hi! link cppAttribute    Comment
hi! link cppNamespace    Identifier
"hi! link cppOperator     cOperator
hi! link cppSTLvariable  cMember
hi! link cppSTLnamespace cppNamespace
"hi! link cppSTLconstant  cppSTLvariable
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

augroup cpp_syntax
    autocmd!
    autocmd VimEnter cpp syntax keyword cppSTLconstant nullptr
augroup END
