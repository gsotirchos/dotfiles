let g:HardMode_hardmodeMsg = '🗿🗿🗿🗿🗿🗿🗿🗿🗿🗿'

nnoremap <Leader>H <Esc>:call ToggleHardMode()<CR>

augroup hardmode
    autocmd BufWinEnter * silent! call HardMode()
augroup END
