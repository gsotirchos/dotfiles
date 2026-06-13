syn match MembOperator "\." containedin=NONE,qmlBindingProperty display
syn match Number "\([0-9]\)\@<=\.\(\h\)\@!" containedin=NONE display
syn match Number "\(\w\)\@<!\.\([0-9]\)\@=" containedin=NONE display
syn match Normal "\:" containedin=qmlBindingProperty display


hi! link qmlDeclaration Statement
hi! link qmlBindingProperty Identifier
hi! link qmlBraces Normal
hi! link qmlObjectLiteralType Type
hi! link qmlType Type
