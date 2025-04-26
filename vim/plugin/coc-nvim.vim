let g:coc_global_extensions = [
\   'coc-marketplace',
\   'coc-git',
\   'coc-json',
\   'coc-pyright',
\   'coc-markdownlint',
\   'coc-texlab',
\]

augroup coc-nvim
    autocmd!
    " Highlight the symbol and its references when holding the cursor
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Refresh diagnostics only after cursor moved
    autocmd CursorHold, CursorHoldI call CocAction('diagnosticRefresh')
augroup END
