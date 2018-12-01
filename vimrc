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
Plugin 'vim-syntastic/syntastic'
Plugin 'lervag/vimtex'
Plugin 'lazywei/vim-matlab'
Plugin 'hdima/python-syntax'
Plugin 'keith/swift.vim'
Plugin 'TheCodedSelf/syntastic-swift'

"" plugins end here
call vundle#end() " required
"""""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" saving settings
autocmd CursorHold ?* nested silent! update " autosave...
set updatetime=300                          " every 300ms
autocmd BufWritePost ?* SyntasticCheck      " and check syntax
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
autocmd BufNewFile,BufRead * silent!
    \ set fileencoding=utf-8 " encoding written to current buffer's file
set fileformats=dos,unix,mac " format order to be tried on a new buffer

" behavior
syntax on
set showcmd    " show typed command
set number
set cursorline " show cursorline
set showmatch  " show matching parentheses

set autoindent
set cindent
set ignorecase
set smartcase  " case sensitive if Uppercase
set hlsearch   " highlight search matches

set sw=4 ts=4 sts=4        " default: 4 spaces per tab
set expandtab              " replace tabs with spaces
set backspace=2            " allow backspace in instert mode
set whichwrap+=h,l,<,>,[,] " fix line movement on line borders
set wrap lbr               " wrap lines by word
set formatoptions+=rawl    " automatic line breaking
autocmd VimEnter,VimResized,TextChanged,TextChangedI *
    \  let &numberwidth = float2nr(log10(line("$"))) + 2
    \| let &textwidth   = &columns - &numberwidth -1 - 2

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

" Python
autocmd BufRead,BufNewFile *.py let python_highlight_all=1
autocmd BufRead,BufNewFile *.py :Python3Syntax

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
autocmd BufNewFile,BufRead *.tex
    \ set spell spelllang=en_us,el " spell check only .tex files

" Syntastic
let g:syntastic_aggregate_errors=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0
let g:syntastic_always_populate_loc_list=1

let g:syntastic_swift_checkers=['swift'] 

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*
set signcolumn=yes

let g:syntastic_error_symbol='x'
let g:syntastic_warning_symbol='▲'
let g:syntastic_style_error_symbol='!?'
let g:syntastic_style_warning_symbol='?'

let g:syntastic_tex_chktex_quiet_messages={'regex': [
    \ 'Command terminated with space.',
    \ 'No match found for',
    \ 'perhaps',
    \ 'doesn''t match the number of',
    \ 'You should put a space in front of',
    \ 'is normally not',
    \ 'You should enclose the previous',
    \ 'Use either `` or '''''
\ ]}
let g:syntastic_tex_lacheck_quiet_messages={'regex': 'unmatched'}
