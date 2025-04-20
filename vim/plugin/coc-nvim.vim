let g:coc_global_extensions = [
\   'coc-marketplace',
\   'coc-git',
\   'coc-json',
\   'coc-pyright',
\   'coc-markdownlint',
\   'coc-texlab',
\]

augroup coc
    autocmd!
    autocmd CursorHold, CursorHoldI call CocAction('diagnosticRefresh')
augroup END
