syntax match swiftMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained

hi! link swiftMark SpecialComment
hi! link swiftAttributes Statement
hi! link swiftImports Statement
