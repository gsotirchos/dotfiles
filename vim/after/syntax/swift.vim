syntax match swiftMark "\(MARK:\s\)\@<=.*" containedin=.*Comment.* contained

hi! link swiftMark NonText
hi! link swiftOperator Operator
