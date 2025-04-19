"xmap gc  <Plug>Commentary
"nmap gc  <Plug>Commentary
"omap gc  <Plug>Commentary
"nmap gcc <Plug>CommentaryLine
"nmap gcu <Plug>Commentary<Plug>Commentary

"nnoremap <Leader>cc       <Plug>Commentary
"onoremap <Leader>c<Space> <Plug>Commentary
"xnoremap <Leader>c<Space> <Plug>Commentary
"nnoremap <Leader>c<Space> <Plug>CommentaryLine
"nnoremap <Leader>cu       <Plug>Commentary<Plug>Commentary

nnoremap <Leader>c<Space> <Nop>
onoremap <Leader>c<Space> <Nop>

augroup commentary
    autocmd FileType *
        \ let b:commentary_format = substitute(&commentstring, ' ', '', 'g')
augroup END
