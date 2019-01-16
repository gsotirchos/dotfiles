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

Plugin 'ervandew/supertab'
Plugin 'scrooloose/nerdcommenter'
Plugin 'w0rp/ale'
Plugin 'lervag/vimtex'
Plugin 'lazywei/vim-matlab'
Plugin 'hdima/python-syntax'
Plugin 'keith/swift.vim'

"" plugins end here
call vundle#end() " required
"""""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" saving settings
set updatetime=750
set undofile             " maintain undo file...
set undodir=~/.vim/undo/ " in ~/.vim/undo/
set noswapfile
set nobackup
set nowb
set history=20 

" colors
set t_Co=256
colorscheme sunyata

" set encodings and line ending formats
set gfs=fixedgr
set fileencodings=ucs-bom,utf-8,cp1253 " encodings to be tried when
set fileencodings+=default,latin1      " starting to edit an existing file
set encoding=utf-8                     " encoding displayed inside vim  
set fileformats=dos,unix,mac " format order to be tried on a new buffer

" behavior
syntax on
set regexpengine=1  " use old regex engine
set showcmd         " show typed command
set number          " show line numbers
set showmatch       " show matching parentheses
set laststatus=0    " hide statusline titles
set splitbelow      " open new windows at bottom
set previewheight=3 " set preview window height to 3

set autoindent
set ignorecase
set smartcase  " case sensitive only if Uppercase
set hlsearch   " highlight search matches

set sw=4 ts=4 sts=4        " default: 4 spaces per tab
set expandtab              " replace tabs with spaces
set backspace=2            " allow backspace in instert mode
set whichwrap+=h,l,<,>,[,] " fix line movement on line borders
set wrap lbr               " wrap lines by word
set formatoptions+=rawl    " automatic line breaking
set nojoinspaces           " don't insert 2 spaces after a '.', '?' or '!'

" allow folding
set foldenable
set foldmethod=indent
set foldlevel=0    " depth of first folding
set foldnestmax=99 " depth of last folding
set foldcolumn=0

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
inoremap <D-v> <Space><ESC>"+gPi<Delete>
nnoremap <D-v> "+p
vnoremap <D-v> "+p
cnoremap <D-v> <C-r>+
vnoremap <D-c> "+y

" other mappings
nnoremap o o<Esc>
let g:SuperTabDefaultCompletionType="<c-n>" " reverse supertab order

" Fortran
let fortran_free_source=1
let fortran_fold=1
let fortran_fold_conditionals=1
let fortran_more_precise=1
let fortran_do_enddo=1

" LaTeX
let g:tex_flavor='latex'
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_TreatMacViewerAsUNIX=1
let g:Tex_ExecuteUNIXViewerInForeground=1
let g:vimtex_view_method='skim'
let g:vimtex_compiler_latexmk={'callback' : 0}
let g:tex_comment_nospell=1

" ALE
let g:ale_cursor_detail=1 " show errors in  preveiew window
let g:ale_echo_cursor=0   " don't show errors in status line
let g:ale_echo_msg_format='%s [%linter%]'
let g:ale_sign_column_always=1
let g:ale_sign_error='⬤'
let g:ale_sign_warning ='▲'

" Autocommands
augroup vimrc
    autocmd!
    autocmd CursorHold ?* nested update " autosave
    autocmd BufWinEnter,Syntax * syn sync minlines=200 maxlines=200
    autocmd VimEnter,VimResized,TextChanged,TextChangedI *
        \  let &numberwidth = float2nr(log10(line("$"))) + 2
        \| let &textwidth   = &columns - &numberwidth - 1
        \| let &colorcolumn = min([&textwidth + 2, 78])
    autocmd BufNewFile,BufRead * silent! set fileencoding=utf-8 " UTF-8
    autocmd BufRead,BufNewFile *.c  set cindent
    autocmd BufRead,BufNewFile *.py let python_highlight_all=1
    autocmd BufRead,BufNewFile *.py :Python3Syntax 
    autocmd BufNewFile,BufRead *.tex
        \ set spell spelllang=en_us,el " spell check only .tex files
augroup END
