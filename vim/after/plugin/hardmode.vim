if get(g:, "HardMode_loaded", 0) == 0
    finish
endif

nnoremap <Leader>H <Esc>:call ToggleHardMode()<CR>
