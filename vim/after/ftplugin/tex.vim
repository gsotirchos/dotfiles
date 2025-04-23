runtime after/ftplugin/markdown.vim
setlocal colorcolumn=+2
setlocal complete-=i  " don't scan included files

let b:tex_flavor = 'latex'
let b:tex_DefaultTargetFormat = 'pdf'
let b:tex_TreatMacViewerAsUNIX = 1
let b:tex_ExecuteUNIXViewerInForeground = 1

let g:tex_comment_nospell = 1
"let g:tex_no_error=1  " don't highlight errors whatsoever
"let g:tex_no_math=1  " don't highlight errors in math
"let g:tex_matchcheck= '[{}]'  " don't check [] and () for mismatches

let g:tex_indent_items = 0
let g:tex_indent_and = 0
let g:tex_indent_brace = 0


nnoremap <buffer> <silent> <C-Return> :CocCommand latex.Build<Return>
nnoremap <buffer> <silent>        :CocCommand latex.Build<Return>
nnoremap <buffer> <silent> <Leader>v  :CocCommand latex.ForwardSearch<Return>
