" Concealling for [[link|title]]
syn match mkdLink "\(\[\[\([^\|\]]*|\)\=\)\@<=[^\|\]]*\(\]\]\)\@="
syn match mkdLink "\(\[\[\([^\|\]]*|\)\=[^\|\]]*\)\@<=\]\]" conceal
syn match mkdLink "\[\[\([^\|\]]*|\)\=\([^\|\]]*\]\]\)\@=" conceal

syntax match mkdStrike "\(\~\~\)\@<=.*\(\~\~\)\@=" containedin=mkdCode display


hi! link Title            SpecialComment
hi! link mkdRule          Info
hi! link mkdHeading       Info
hi! link mkdDelimiter     Info
hi! link mkdCodeStart     Info
hi! link mkdCodeEnd       Info
hi! link mkdURL           MyUrl
hi! link mkdCode          String
hi! link mkdCodeDelimiter OtherType
hi! link mkdStrike        MyStrikethrough
hi! link htmlTag          Info
hi! link htmlEndTag       htmlTag
