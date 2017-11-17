"
" ~/.vimrc
"

"""""""""""""""""""""""""""""""""""""""""""
set nocompatible " be iMproved, required
filetype off     " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"" plugins start here

Plugin 'lervag/vimtex'
Plugin 'ervandew/supertab'
Plugin 'scrooloose/nerdcommenter'
"Plugin 'reedes/vim-lexical'

"" plugins end here
call vundle#end() " required
"""""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" no swap files
set noswapfile
set nobackup
set nowb

" allow use of backspace in instert mode
set backspace=indent,eol,start

set t_Co=256

colorscheme sunyata

set number
set showmatch " show matching parentheses
syntax on

set gfs=fixedgr

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
"let g:Tex_ViewRule_ps = 'open -a Skim'
"let g:Tex_ViewRule_pdf = 'open -a Skim'
"let g:Tex_ViewRule_dvi = 'open -a Skim'
let g:vimtex_view_general_viewer = '/Applications/Skim.app/Contents/SharedSupport/displayline'
let g:vimtex_view_general_options = '-r @line @pdf @tex'
let g:vimtex_view_general_options_latexmk = '-r 1'
let g:vimtex_compiler_latexmk = {'callback' : 0}
let g:tex_comment_nospell= 1
autocmd BufNewFile,BufRead *.tex set spell spelllang=en_us,el " spell check only .tex files
