syntax match prologMyStrComment "\(%!\s*\)\@<=.*" containedIn=.*Comment.* contained
syntax match prologMyString "\"\S*\"" containedIn=ALLBUT,.*Comment.*
syntax match prologMyParens "[()]" containedIn=ALLBUT,.*Comment.*
syntax match prologMySeparator "[;,.]" containedIn=prologPredicate
syntax match Normal "\((.*\)\@<=[,:]\(.*)\)\@=" containedIn=prologPredicate contained
syntax match prologISOBuiltIn "[!]" containedIn=prologRelations  " '!'
syntax match prologArithmetic "\([^:?]\)\@<=-" containedIn=prologPredicate  " '-'
syntax match prologISOBuiltIn "[:?]-"

hi! link prologPredicate OtherType
hi! link prologSWIBuiltIn prologPredicate
hi! link prologPredicateWithArity prologPredicate
hi! link prologArity Normal
hi! link prologVariable Function
hi! link prologAtom Identifier
hi! link prologBody Normal
hi! link prologRelations Normal
hi! link prologList prologBody
hi! link prologListDelimiters prologBody
hi! link prologMyParens prologBody
hi! link prologMyString String
hi! link prologMyStrComment SpecialComment
hi! link prologMySeparator prologISOBuiltIn
