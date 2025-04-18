nnoremap <Leader>cc       <Plug>Commentary
onoremap <Leader>c<Space> <Plug>Commentary
xnoremap <Leader>c<Space> <Plug>Commentary
nnoremap <Leader>c<Space> <Plug>CommentaryLine
nnoremap <Leader>cu       <Plug>Commentary<Plug>Commentary

augroup commentary
    autocmd FileType *
    \   let b:commentary_format = substitute(&commentstring, ' ', '', 'g')
augroup END
