let python_highlight_all=1

syntax region pythonLongComment
\   start="\"\"\""
\   end="\"\"\""
\   containedin=.*String.*

syntax match myOperator "[-+=?!$%^&*\\|~/:<>]" containedIn=pythonOperator

hi! link pythonLongComment String
hi! link myOperator        Normal
hi! link pythonOperator    Statement
"hi! link pythonDot         MembOperator
hi! link pythonImport      Statement
hi! link pythonNone        Identifier
hi! link pythonClass       Identifier
hi! link pythonDecorator   Identifier
hi! link pythonBuiltinObj  Function
hi! link pythonBuiltinType OtherType
