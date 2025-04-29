" Concealling for [[link|title]]
syn match mkdLink "\(\[\[\([^\|\]]*|\)\=\)\@<=[^\|\]]*\(\]\]\)\@="
syn match mkdLink "\(\[\[\([^\|\]]*|\)\=[^\|\]]*\)\@<=\]\]" conceal
syn match mkdLink "\[\[\([^\|\]]*|\)\=\([^\|\]]*\]\]\)\@=" conceal

syn match mkdHighlighted "==.\{-}==" containedin=ALL contains=TOP display
syn match mkdHighlighted "==" containedin=mkdHighlighted conceal

syn match mkdStrike "\(\~\~\)\@<=.*\(\~\~\)\@=" containedin=mkdCode display

hi! link Title            SpecialComment
hi! link mkdRule          Dimmed
hi! link mkdHeading       Dimmed
hi! link mkdDelimiter     MembOperator
hi! link mkdCodeDelimiter mkdDelimiter
hi! link mkdCodeStart     Dimmed
hi! link mkdCodeEnd       mkdCodeStart
hi! link mkdLink          MyUrl
hi! link mkdCode          String
hi! link mkdStrike        MyStrikethrough
hi! link mkdHighlighted   IncSearch
hi! link htmlTag          Dimmed
hi! link htmlEndTag       htmlTag
