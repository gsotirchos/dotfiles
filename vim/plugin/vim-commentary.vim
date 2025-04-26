augroup commentary
    autocmd FileType * let b:commentary_format = substitute(&commentstring, ' ', '', 'g')
augroup END
