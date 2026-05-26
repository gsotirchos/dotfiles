scriptencoding utf-8

let g:HardMode_hardmodeMsg = '🗿🗿🗿🗿🗿🗿🗿🗿🗿🗿'

augroup hardmode
    autocmd BufWinEnter * silent! call HardMode()
augroup END
if get(g:, 'HardMode_loaded', 0) ==# 0
    finish
endif

nnoremap <Leader>H <Esc>:call ToggleHardMode()<CR>
