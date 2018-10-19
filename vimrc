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
Plugin 'lazywei/vim-matlab'
Plugin 'justinmk/vim-syntax-extra'

"" plugins end here
call vundle#end() " required
"""""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" no swap files
set noswapfile
set nobackup
set nowb

" colors
set t_Co=256
colorscheme sunyata

" greek
set gfs=fixedgr

" unix line endings
set fileformat=unix

syntax on
set showcmd
set number
set showmatch " show matching parentheses

set autoindent
set cindent
set smartcase
set hlsearch

set sw=4 ts=4 sts=4 " default: 4 spaces per tab
set expandtab " replace tabs with spaces

set backspace=2 " allow backspace in instert mode
set whichwrap+=h,l,<,>,[,] " fix line border movement
set wrap lbr  " wrap lines by word

" allow folding
set foldenable
set foldmethod=indent
set foldlevel=0
set foldnestmax=99
set foldcolumn=0

set cursorline

" fix movement in wrapped lines
noremap  <buffer> <silent> k       gk
noremap  <buffer> <silent> j       gj
noremap  <buffer> <silent> <up>    gk
noremap  <buffer> <silent> <down>  gj
noremap  <buffer> <silent> <home>  g<home>
noremap  <buffer> <silent> <End>   g<End>
noremap  <buffer> <silent> 0       g0
noremap  <buffer> <silent> $       g$
noremap  <buffer> <silent> ^       g^
noremap  <buffer> <silent> <space> za
inoremap <buffer> <silent> <Down>  <C-o>gj
inoremap <buffer> <silent> <Up>    <C-o>gk
inoremap <buffer> <silent> <home>  <C-o>g<home>
inoremap <buffer> <silent> <End>   <C-o>g<End>

" smart indent when entering insert mode with i on empty lines
function! IndentWithI()
    if len(getline('.')) == 0
        return "\"_cc"
    else
        return "i"
    endif
endfunction
nnoremap <expr> i IndentWithI()

function! IndentWithA()
    if len(getline('.')) == 0
        return "\"_cc"
    else
        return "a"
    endif
endfunction
nnoremap <expr> a IndentWithA()

" use OS clipboard and copy-paste shortcuts
set clipboard=unnamed
inoremap <D-v> <Space><ESC>"+gPs
nnoremap <D-v> "+p
vnoremap <D-v> "+p
cnoremap <D-v> <C-r>+
vnoremap <D-c> "+y

" other mappings
nnoremap o o<Esc>

" Fortran
let fortran_free_source=1
let fortran_fold=1
let fortran_fold_conditionals=1
let fortran_more_precise=1
let fortran_do_enddo=1

" LaTeX
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_TreatMacViewerAsUNIX = 1
let g:Tex_ExecuteUNIXViewerInForeground = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_compiler_latexmk = {'callback' : 0}
let g:tex_comment_nospell= 1
autocmd BufNewFile,BufRead *.tex set spell spelllang=en_us,el " spell check only .tex files
