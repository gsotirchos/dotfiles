syntax match prologMyStrComment "\(%!\s*\)\@<=.*" containedin=.*Comment.* contained
syntax match prologMyString "\"\S*\"" containedin=ALLBUT,.*Comment.* display
syntax match prologMyParens "[()]" containedin=ALLBUT,.*Comment.* display
syntax match prologMySeparator "[;,.]" containedin=prologPredicate display
syntax match Normal "\((.*\)\@<=[,:]\(.*)\)\@=" containedin=prologPredicate contained
syntax match prologISOBuiltIn "[!]" containedin=prologRelations display  " '!'
syntax match prologArithmetic "\([^:?]\)\@<=-" containedin=prologPredicate display  " '-'
syntax match prologISOBuiltIn "[:?]-" display


hi! link prologPredicate          OtherType
hi! link prologSWIBuiltIn         prologPredicate
hi! link prologPredicateWithArity prologPredicate
hi! link prologArity              Normal
hi! link prologVariable           Function
hi! link prologAtom               Identifier
hi! link prologBody               Normal
hi! link prologRelations          Normal
hi! link prologList               prologBody
hi! link prologListDelimiters     prologBody
hi! link prologMyParens           prologBody
hi! link prologMyString           String
hi! link prologMyStrComment       SpecialComment
hi! link prologMySeparator        prologISOBuiltIn
