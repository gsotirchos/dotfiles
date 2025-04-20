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
hi! link mkdDelimiter     Dimmed
hi! link mkdCodeStart     Dimmed
hi! link mkdCodeEnd       Dimmed
hi! link mkdLink          MyUrl
hi! link mkdCode          String
hi! link mkdCodeDelimiter OtherType
hi! link mkdStrike        MyStrikethrough
hi! link mkdHighlighted   IncSearch
hi! link htmlTag          Dimmed
hi! link htmlEndTag       htmlTag
