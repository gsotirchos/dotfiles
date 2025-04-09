let g:vimtex_view_method = 'skim'
let g:vimtex_view_skim_reading_bar = 1
let g:vimtex_view_skim_sync = 0  " don't forward jump to edited location in PDF

let g:vimtex_quickfix_mode = 2  " open the quickfix window but don't focus
let g:vimtex_quickfix_open_on_warning = 0  " don't open the quickfix window with only warnings
let g:vimtex_quickfix_autoclose_after_keystrokes = 0
let g:vimtex_quickfix_ignore_filters = []  " filter out undesired warnings/errors

let g:vimtex_compiler_latexmk = {
    \ 'aux_dir' : '',
    \ 'out_dir' : '',
    \ 'callback' : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'hooks' : [],
    \ 'options' : [
    \   '-pdf',
    \   '-shell-escape',
    \   '-verbose',
    \   '-file-line-error',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \   '-bibtex',
    \ ],
\}

let g:vimtex_syntax_nospell_comments = 1
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
