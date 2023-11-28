" vimtex
let g:vimtex_syntax_nospell_comments = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_sync = 1
let g:vimtex_view_skim_reading_bar = 1
"let g:vimtex_compiler_latexmk = {'callback': 0}  " don't show QuickFix List

let g:vimtex_syntax_conceal = {
\   'fancy': 1,
\   'accents': 1,
\   'ligatures': 1,
\   'greek': 0,
\   'math_symbols': 0,
\   'math_fracs': 0,
\   'math_super_sub': 0,
\   'math_delimiters': 0,
\   'math_bounds': 0,
\   'sections': 1,
\   'cites': 1,
\   'styles': 0,
\}

let g:vimtex_delim_toggle_mod_list = [
\   ['\l', '\r'],
\   ['\left', '\right']
\]

