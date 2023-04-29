" marks
syntax match Done "DONE\(\W.*\)\@=" containedin=.*Comment.* contained
syntax match myMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained
syntax match myUrl "http.:\/\/\S*" containedin=.*Comment.* contained

hi! link myMark SpecialComment
hi! link myUrl underlined
