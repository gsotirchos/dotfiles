let g:haskell_enable_quantification = 1   "  highlighting of `forall`
let g:haskell_enable_recursivedo = 1      "  highlighting of `mdo` & `rec`
let g:haskell_enable_arrowsyntax = 1      "  highlighting of `proc`
let g:haskell_enable_pattern_synonyms = 1 "  highlighting of `pattern`
let g:haskell_enable_typeroles = 1        "  highlighting of type roles
let g:haskell_enable_static_pointers = 1  "  highlighting of `static`
let g:haskell_backpack = 1                "  highlght. of backpack keywords

"let g:haskell_indent_if = 3
"let g:haskell_indent_case = 2
"let g:haskell_indent_let = 4
"let g:haskell_indent_where = 6
let g:haskell_indent_before_where = 2
let g:haskell_indent_after_bare_where = 2
"let g:haskell_indent_do = 3
"let g:haskell_indent_in = 1
"let g:haskell_indent_guard = 2
let g:haskell_indent_case_alternative = 2
let g:cabal_indent_section = 2

hi! link haskellKeyword     Statement
hi! link haskellWhere       Statement
hi! link haskellConditional Statement
