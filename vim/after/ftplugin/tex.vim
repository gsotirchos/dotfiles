runtime after/ftplugin/markdown.vim
setlocal colorcolumn=+2
setlocal complete-=i  " don't scan included files

let b:tex_flavor = 'latex'
let b:tex_DefaultTargetFormat = 'pdf'
let b:tex_TreatMacViewerAsUNIX = 1
let b:tex_ExecuteUNIXViewerInForeground = 1
let b:tex_comment_nospell = 1

let b:tex_indent_items = 0
let b:tex_indent_and = 0
let b:tex_indent_brace = 0


" single-shot compile with Ctrl/Cmd+Return
nnoremap <buffer> <silent> <C-Return> :CocCommand latex.Build<Return>
nnoremap <buffer> <silent>  :CocCommand latex.Build<Return>
