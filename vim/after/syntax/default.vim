" marks
syntax match Done "DONE\(\W.*\)\@=" containedin=.*Comment.* contained
syntax match myMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained
syntax match myUrl "http.:\/\/\S*" containedin=.*Comment.* contained

hi! link myParens Comment
hi! link myOperator OtherType
hi! link myMark SpecialComment
hi! link myUrl underlined
