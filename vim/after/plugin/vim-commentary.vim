if get(g:, "loaded_commentary", 0) == 0
    finish
endif

"xmap gc  <Plug>Commentary
"nmap gc  <Plug>Commentary
"omap gc  <Plug>Commentary
"nmap gcc <Plug>CommentaryLine
"nmap gcu <Plug>Commentary<Plug>Commentary

"xnoremap <Leader>c<Space> <Plug>Commentary
"nnoremap <Leader>c<Space> <Plug>CommentaryLine
"onoremap <Leader>c<Space> <Plug>Commentary
"nnoremap <Leader>cc       <Plug>Commentary
"nnoremap <Leader>cu       <Plug>Commentary<Plug>Commentary

nnoremap <Leader>c<Space> :echo "🗿🗿🗿🗿🗿🗿🗿🗿🗿🗿"<Return>
vnoremap <Leader>c<Space> <Esc>:echo "🗿🗿🗿🗿🗿🗿🗿🗿🗿🗿"<Return>
