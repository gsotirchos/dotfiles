hi! link Title            SpecialComment
hi! link mkdRule          Info
hi! link mkdCodeDelimiter OtherType
hi! link mkdHeading       Info
hi! link mkdDelimiter     Info
hi! link htmlTag          Info
hi! link htmlEndTag       htmlTag
hi! link mkdCode          String
hi! link mkdStrike        MyStrikethrough


syntax match mkdStrike "\(\~\~\)\@<=.*\(\~\~\)\@=" containedin=mkdCode display

" Concealling for [[link|title]]
syn match mkdLink "\(\[\[\([^\|\]]*|\)\=\)\@<=[^\|\]]*\(\]\]\)\@="
syn match mkdLink "\(\[\[\([^\|\]]*|\)\=[^\|\]]*\)\@<=\]\]" conceal
syn match mkdLink "\[\[\([^\|\]]*|\)\=\([^\|\]]*\]\]\)\@=" conceal
