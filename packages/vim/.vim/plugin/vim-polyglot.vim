" Polyglot bundles stale copies of Vim's own runtime files. 'yaml' is disabled
" so the maintained $VIMRUNTIME yaml syntax/ftplugin/indent win: polyglot's
" 2021 indent/yaml.vim predates two upstream fixes -- it still has '0#' in
" 'indentkeys' and applies the multiline-scalar rule unconditionally, so typing
" '#' anywhere below the second line re-indents by a shiftwidth.
" Must be set before the package loads; plugin/ is sourced first (:h load-plugins).
let g:polyglot_disabled = ['autoindent', 'sensible', 'yaml']

" https://github.com/vim-python/python-syntax
let g:python_highlight_all = 1

" https://github.com/preservim/vim-markdown
"let g:vim_markdown_auto_insert_bullets = 1
let g:vim_markdown_math = 1
let g:vim_markdown_strikethrough = 1
let g:vim_markdown_new_list_item_indent = 2
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_folding_disabled = 1
