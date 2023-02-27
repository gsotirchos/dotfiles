syntax match prologMyParens "[()]" containedIn=ALL
"syntax match prologMyString '\"\S\*\"' TODO

hi! link prologSWIBuiltIn Function
hi! link prologPredicate Statement
hi! link prologVariable Identifier
hi! link prologAtom Type
hi! link prologBody Normal
hi! link prologList prologBody
hi! link prologMyParens prologBody
hi! link prologMyString String
