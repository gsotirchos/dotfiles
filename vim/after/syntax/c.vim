syntax match cMemberAccess "::" containedin=NONE
"syntax match myMemberOperator "\([a-zA-Z_][a-zA-Z0-9_]*\)\@<=->\([a-zA-Z_]\)\@=" containedin=NONE
"syntax match myMemberOperator "\([a-zA-Z_][a-zA-Z0-9_]*\)\@<=->\([a-zA-Z_]\)\@=" containedin=NONE
syntax region Mark start="\(\".*\)\@<!%\@<=" end="%\@=" containedin=.*Comment.* contained oneline

hi! link cMemberAccess myMemberOperator
hi! link cCustomScope myMemberOperator
hi! link cFormat Type
