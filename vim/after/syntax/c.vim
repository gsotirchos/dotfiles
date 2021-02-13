"syntax match myMemberOperator "::" containedin=NONE
syntax match myMemberOperator "\([a-zA-Z_][a-zA-Z0-9_]*\)\@<=->\([a-zA-Z_]\)\@=" containedin=NONE
syntax match myMemberOperator "\([a-zA-Z_][a-zA-Z0-9_]*\)\@<=->\([a-zA-Z_]\)\@=" containedin=NONE
syntax region Mark start="\(\".*\)\@<!%\@<=" end="%\@=" containedin=.*Comment.* contained oneline

hi! link cMemberAccess MemOperator
hi! link cCustomScope MembOperator
hi! link myMemberOperator MembOperator
hi! link cFormat Type
