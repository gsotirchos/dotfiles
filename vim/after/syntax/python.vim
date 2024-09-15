let python_highlight_all=1

" syntax region pythonLongComment
" \   start="\"\"\""
" \   end="\"\"\""
" \   containedin=.*String.*

syntax match myOperator "\A" contained containedin=pythonOperator display


"hi! link pythonLongComment pythonString
hi! link pythonDot         MembOperator
"hi! link pythonOperator    Statement
hi! link pythonImport      Statement
"hi! link pythonNone        Function
hi! link pythonBuiltinObj  Function
hi! link pythonClass       Identifier
hi! link PythonExClass     Type
hi! link pythonBuiltinType Type
hi! link pythonDottedName  OtherType
hi! link pythonDecorator   pythonDottedName

" vim-easytags
hi! link pythonClassTag    pythonClass
