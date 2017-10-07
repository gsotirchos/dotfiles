"
" ~/.vimrc
"

filetype plugin indent on

" no swap files
set noswapfile
set nobackup
set nowb

" allow use of backspace in instert mode
set backspace=indent,eol,start

set t_Co=256

colorscheme organic

set number
set showmatch " show matching parentheses
syntax on

" enable foldcolumn
set foldcolumn=1

set sw=4 ts=4 sts=4 " default: 4 spaces per tab
set expandtab

set autoindent
set smartcase
set hlsearch

set wrap lbr  " wrap lines by word
" fix up down movement in wrapped lines
noremap  <buffer> <silent> k gk
noremap  <buffer> <silent> j gj
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$
noremap  <buffer> <silent> <up> g<up>
noremap  <buffer> <silent> <down> g<down>

"LaTeX"
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_TreatMacViewerAsUNIX = 1
let g:Tex_ExecuteUNIXViewerInForeground = 1
let g:Tex_ViewRule_ps = 'open -a Skim'
let g:Tex_ViewRule_pdf = 'open -a Skim'
let g:Tex_ViewRule_dvi = 'open -a Skim'
