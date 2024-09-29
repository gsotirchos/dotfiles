set nonumber
set wrap


" Remap <Return> so that it won't switch buffers in QuickFix/LocList buffers
autocmd FileType qf nnoremap <buffer> <Return> <Return><C-W><C-W>
