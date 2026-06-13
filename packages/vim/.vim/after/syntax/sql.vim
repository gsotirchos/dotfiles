"syn match MembOperator ";"
syn match Normal "(\|)" display
syn match sqlStatement "\(\S\)\@<!\(USE\|SHOW\|SET\)" display
syn clear sqlFunction
syn match sqlFunction "\(\S\)\@<!\.\h\w\+" display


hi! link sqlOperator    Statement
hi! link sqlKeyword     Statement
hi! link sqlQuote       String
hi! link sqlType        Othertype
hi! link Quote          String
hi! link sqlConditional Normal
