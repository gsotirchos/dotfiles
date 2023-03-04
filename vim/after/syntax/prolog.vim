syntax match prologMyStrComment "\(%!\s*\)\@<=.*" containedin=.*Comment.* contained
syntax match prologMyParens "[()]" containedIn=ALLBUT,.*Comment.*
syntax match prologMyString "\"\S*\"" containedIn=ALLBUT,.*Comment.*
syntax match prologArithmetic "\([^:?]\)\@<=-" containedIn=prologPredicate  " '-'
syntax match prologPredicate "!" containedIn=prologRelations  " '!'

hi! link prologSWIBuiltIn Function
hi! link prologPredicate Statement
hi! link prologVariable Identifier
hi! link prologAtom Type
hi! link prologBody Normal
hi! link prologRelations Normal
hi! link prologList prologBody
hi! link prologListDelimiters prologBody
hi! link prologMyParens prologBody
hi! link prologMyString String
hi! link prologMyStrComment SpecialComment
