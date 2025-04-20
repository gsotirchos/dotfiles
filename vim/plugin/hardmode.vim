let g:HardMode_hardmodeMsg = '🗿🗿🗿🗿🗿🗿🗿🗿🗿🗿'

nnoremap <Leader>H <Esc>:call ToggleHardMode()<CR>

augroup hardmode
    autocmd VimEnter,BufNewFile,BufReadPost * silent! call HardMode()
augroup END
