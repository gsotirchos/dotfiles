syn match MembOperator "\." containedIn=NONE,qmlBindingProperty
syn match Number "\([0-9]\)\@<=\.\(\h\)\@!" containedIn=NONE
syn match Number "\(\w\)\@<!\.\([0-9]\)\@=" containedIn=NONE
syn match Normal "\:" containedIn=qmlBindingProperty

hi! link qmlDeclaration Statement
hi! link qmlBindingProperty Identifier
hi! link qmlBraces Normal
hi! link qmlObjectLiteralType Type
hi! link qmlType Type

