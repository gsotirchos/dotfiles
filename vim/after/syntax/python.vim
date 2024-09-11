let python_highlight_all=1

" syntax region pythonLongComment
" \   start="\"\"\""
" \   end="\"\"\""
" \   containedin=.*String.*

syntax match myParens "[(){}\[\]<>,;]" containedin=NONE
syntax match myOperator "[-+?!$%^&*\\|~/:<>]" containedIn=pythonOperator
syntax match myEquals "=" containedIn=pythonOperator

hi! link pythonLongComment pythonString
hi! link myParens          Comment
hi! link myOperator        OtherType
hi! link myEquals          Statement
hi! link pythonDot         MembOperator
hi! link pythonOperator    Statement
hi! link pythonImport      Statement
hi! link pythonNone        Function
hi! link pythonBuiltinObj  Function
hi! link pythonClass       Identifier
hi! link PythonExClass     Type
hi! link pythonBuiltinType Type
hi! link pythonDottedName  Type
hi! link pythonDecorator   pythonDottedName

" vim-easytags
hi! link pythonClassTag    pythonClass
