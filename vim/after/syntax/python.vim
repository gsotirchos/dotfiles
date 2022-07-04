let python_highlight_all=1

syntax region pythonLongComment
\   start="\"\"\""
\   end="\"\"\""
\   containedin=.*String.*

syntax match myOperator "[-+=?!$%^&*\\|~/:<>]" containedIn=pythonOperator

hi! link myOperator        pythonOperator
hi! link pythonLongComment String
"hi! link pythonDot         MembOperator
hi! link pythonImport      Statement
hi! link pythonNone        Function
hi! link pythonClass       Identifier
hi! link pythonDecorator   Identifier
hi! link pythonBuiltinObj  Function
hi! link pythonBuiltinType OtherType

" vim-easytags
hi! link pythonClassTag    pythonClass
