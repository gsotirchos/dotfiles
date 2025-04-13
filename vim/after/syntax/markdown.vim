hi! link Title            SpecialComment
hi! link mkdRule          Info
hi! link mkdCodeDelimiter mkdCode
hi! link mkdHeading       Info
hi! link mkdDelimiter     Info
hi! link htmlTag          Info
hi! link htmlEndTag       htmlTag
"hi! link mkdCode          MyStrikethrough
hi! link mkdCode          String

syntax match MyStrikethrough "\(\~\~\)\@<=.*\(\~\~\)\@=" containedin=mkdCode display

