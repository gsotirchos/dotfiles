" nerdcommenter
let g:NERDToggleCheckAllLines = 1  " check every selected line
let g:NERDUsePlaceHolders = 0  " don't use placeholders for nested comments
let g:NERDDefaultAlign = 'left'  " flush left comment delimiters
let g:NERDCommentEmptyLines = 1  " comment empty lines too
let g:NERDAltDelims_swift = 1  " use // instead of /* */ in swift
let g:NERDRemoveAltComs = 1  " also remove alternative comments
let g:NERDSpaceDelims = 0  " don't add extra spaces around delimiters
let g:NERDRemoveExtraSpaces = 1  " remove extra spaces around delimiters
let g:NERDTrimTrailingWhitespace  = 1  " remove trailing spaces after delimiters

let g:NERDCustomDelimiters = {
\   'python': {'left': '#', 'leftAlt': '"""', 'rightAlt': '"""'},
\   'cpp': {'left': '//', 'leftAlt': '/*', 'rightAlt': '*/'},
\   'vimwiki': {'left': '<!--', 'right': '-->'},
\}
