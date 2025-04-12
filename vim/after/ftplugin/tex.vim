runtime after/ftplugin/markdown.vim
set colorcolumn=+2
set complete-=i  " don't scan included files

let g:tex_flavor = 'latex'
let g:tex_DefaultTargetFormat = 'pdf'
let g:tex_TreatMacViewerAsUNIX = 1
let g:tex_ExecuteUNIXViewerInForeground = 1
let g:tex_comment_nospell = 1

let g:tex_indent_items = 0
let g:tex_indent_and = 0
let g:tex_indent_brace = 0


" single-shot compile with Ctrl/Cmd+Return
nnoremap <buffer> <silent> <C-Return> :CocCommand latex.Build<Return>
nnoremap <buffer> <silent>  :CocCommand latex.Build<Return>
