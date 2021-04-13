"
" ~/.vimrc
"

"""""""""""""""""""""""""""""""""""""""""""
set nocompatible " be iMproved, required
filetype off     " required

" set the runtime path to include Vundle and initialize
set rtp+=$HOME/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"" plugins start here

Plugin 'scrooloose/nerdcommenter'
Plugin 'w0rp/ale'
Plugin 'lifepillar/vim-mucomplete'
Plugin 'xavierd/clang_complete'
Plugin 'octol/vim-cpp-enhanced-highlight'
Plugin 'vim-python/python-syntax'
Plugin 'neovimhaskell/haskell-vim'
Plugin 'bitc/vim-hdevtools'
Plugin 'keith/swift.vim'
Plugin 'JuliaEditorSupport/julia-vim'
Plugin 'lervag/vimtex'
Plugin 'PProvost/vim-ps1'

"" plugins end here
call vundle#end() " required
"""""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" saving
set updatetime=750
set undofile  " maintain undo file...
set undodir=$HOME/.vim/undo/  " in ~/.vim/undo/
set noswapfile
set nobackup
set nowb
set history=20

" appearance
set t_Co=256
colorscheme sunyata
set noshowcmd          " hide typed command
set number             " show line numbers
set showmatch          " show matching parentheses
set laststatus=1       " hide statusline titles
set fillchars+=fold:\  " set folding separator to ' '
set showbreak=...      " show '...' at start of wrapped lines
set list               " show non-text characters
let &listchars = 'tab:| ,trail:_'

" set encodings and line ending formats
set gfs=fixedgr
set fileencodings=ucs-bom,utf-8,cp1253,default,latin1  " tried on open
set encoding=utf-8  " encoding displayed inside vim
set fileformats=unix,mac,dos  " format order to be tried on a new buffer

" behaviour
set regexpengine=1   " use old regex engine
set mouse=a          " enable mouse
set splitbelow       " open new horizontal windows at bottom
set splitright       " open new vertical windows at right
set previewheight=3  " set preview window height to 3
set autoindent       " autointent
set sw=4 ts=4 sts=4  " default: 4 spaces per tab
set expandtab        " replace tabs with spaces
set nojoinspaces     " don't insert 2 spaces after '.', '?' or '!'
set backspace=2      " allow backspace in insert mode
set scrolloff=3      " scroll before reaching last line
set whichwrap+=h,l,<,>,[,]  " fix line movement on line borders
set wrap lbr             " wrap lines by word
set formatoptions=ro     " no automatic line breaking
set display+=lastline    " show last wrapped line in window
let colorcolumnposition = 81  " position of column to mark text width
set shell=$SHELL\ -l     " login shell for 'term'
set shellcmdflag=-l\ -c  " login shell for '!'
set noshellslash

" folding
set foldenable
set foldmethod=indent
set foldlevel=99    " depth of first folding
set foldnestmax=99 " depth of last folding
set foldcolumn=0

" searching
set smartcase  " case sensitive only if Uppercase
set hlsearch   " highlight search matches

" autocompletion
set completeopt-=preview
set completeopt+=menuone,noselect,noinsert
set complete-=u,t
set shortmess+=c  " shut off completion messages
set belloff+=ctrlg  " silent completion
let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#chains = {
\   'default': ['path', 'omni', 'keyn', 'dict', 'uspl'],
\   'cmake': {
\       'cmakeComment': [],
\       'default': ['dict', 'path', 'omni', 'keyn', 'uspl']
\   },
\   'vim': ['path', 'cmd', 'keyn']
\}

" autocompletion mappings
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
inoremap <expr> <C-n> pumvisible() ? "\<Down>" : ""
inoremap <expr> <C-j> pumvisible() ? "" : "\<C-j>"
inoremap <expr> <C-p> pumvisible() ? "\<Up>" : ""
inoremap <expr> <C-k> pumvisible() ? "" : "\<C-k>"

" wrapped lines movement mappings
noremap  <buffer> <silent> <Up>    gk
inoremap <buffer> <silent> <Up>    <C-o>gk
noremap  <buffer> <silent> <Down>  gj
inoremap <buffer> <silent> <Down>  <C-o>gj
noremap  <buffer> <silent> j       gj
noremap  <buffer> <silent> k       gk
noremap  <buffer> <silent> <Home>  g<home>
inoremap <buffer> <silent> <Home>  <C-o>g<home>
noremap  <buffer> <silent> <End>   g<End>
inoremap <buffer> <silent> <End>   <C-o>g<End>
noremap  <buffer> <silent> 0       g0
noremap  <buffer> <silent> ^       g^
noremap  <buffer> <silent> $       g$
noremap  <buffer> <silent> <Space> za

" execute last command with C-@
noremap  <silent> <C-@> :@:<CR>
inoremap <silent> <C-@> <Esc>:@:<CR>
cnoremap <silent> <C-@> <C-e><C-u>@:<CR>

" print highlight group under cursor
map <F10> :echo
\   'hi<' . synIDattr(synID(line("."),col("."),1),"name") . '> ' .
\   'trans<' . synIDattr(synID(line("."),col("."),0),"name") . '> ' .
\   'lo<' . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . '>'
\   <CR>

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
set clipboard=unnamed,unnamedplus
"inoremap <D-v> <Space><ESC>"+gPi<Delete>
inoremap <D-v> <C-r>+
nnoremap <D-v> "+p
vnoremap <D-v> "+p
cnoremap <D-v> <C-r>+
vnoremap <D-c> "+y

" show loclist
function! LocListToggle()
    if get(getloclist(0, {'winid':0}), 'winid', 0)
        lclose
    else
        lopen
    endif
endfunction
nnoremap <silent> <leader>l :call LocListToggle()<CR>

" ignorecase when searching by using '\c'
noremap <silent> / :echo '/'<CR>/\c
noremap <silent> ? :echo '?'<CR>?\c

" other mappings
let mapleader = ";"
nnoremap o o<Esc>

" nerdcommenter
let g:NERDDefaultAlign = 'left' " flush left comment delimiters
let g:NERDCommentEmptyLines = 1 " comment empty lines too
let g:NERDAltDelims_swift = 1   " use // instead of /* */ in swift

" Fortran
let fortran_free_source = 1
let fortran_fold = 1
let fortran_fold_conditionals = 1
let fortran_more_precise = 1
let fortran_do_enddo = 1

" LaTeX
let g:tex_flavor = 'latex'
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_TreatMacViewerAsUNIX = 1
let g:Tex_ExecuteUNIXViewerInForeground = 1
let g:vimtex_view_method = 'skim'
let g:vimtex_compiler_latexmk = {'callback' : 0}
let g:tex_comment_nospell = 1

" ALE
let g:ale_list_window_size = 6
let g:ale_echo_msg_format = '%linter%::%severity%% code% -- %s'
let g:ale_sign_column_always = 1
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '!'

" clang_complete
if has('mac')
    let g:clang_library_path =
    \   '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
else
    let g:clang_library_path =
    \   '/Library/Developer/CommandLineTools/usr/lib/libclang.dylib'
endif


" functions
function! SetSignColumn(file_name, is_modifiable)
    if empty(a:file_name) || !a:is_modifiable
        let &signcolumn = 'no'
        let b:gutterwidth = 0
    else
        let &signcolumn = 'yes'
        let b:gutterwidth = 2
    endif
endfunction

" Autocommands
augroup vimrc
    autocmd!

    " enable sign column (when appropriate) and set status-line
    autocmd BufWinEnter,BufRead,BufWrite *
    \   call SetSignColumn(@%, &modifiable)
    \|  let &statusline = '%h%w%F%m%a% = %l, %c'

    " set color column to 81th character
    autocmd BufWinEnter,VimResized,TextChanged,TextChangedI,OptionSet *
    \   let &numberwidth = float2nr(log10(line('$'))) + 2
    \|  let &textwidth   =
    "\     colorcolumnposition - 2 - &numberwidth*&number - b:gutterwidth
    \     &columns - 2 - &numberwidth*&number - b:gutterwidth
    \|  let &colorcolumn =
    \     colorcolumnposition - b:gutterwidth - &numberwidth*&number

    " autosave named files
    autocmd CursorHold ?* nested if empty(&buftype) | update | endif

    " convert everything to utf-8
    autocmd BufWinEnter,BufRead,BufWrite ?* silent! set fileencoding=utf-8

    " spell check text files
    autocmd FileType tex,latex,text,markdown
    \   set formatoptions+=tawcroql
    \|  set spell spelllang=en_us,el,cjk

    " limit amount of syntax lines
    autocmd Syntax * syn sync minlines=200 maxlines=200

    " enable syntax & load default syntax for non-text files
    let textFiletypes =
    \   ['xml', 'yaml', 'markdown', 'qf', 'help', 'tex', 'latex', 'text', '']
    autocmd BufWinEnter,BufRead *
    \   nested if !exists("g:syntax_on")
    \|      syntax on
    \|  endif
    \|  if index(textFiletypes, &filetype) < 0
    \|      source $HOME/.vim/after/syntax/default.vim
    \|  endif

    " use xml syntax for some extensions
    autocmd BufWinEnter,BufRead,BufWrite
    \   *.sdf,*.world,*.model,*.config,*.launch set ft=xml

    autocmd BufWinEnter,BufRead,BufWrite CMakeLists.txt
    \   set complete=.,k
    \|  set dictionary=$HOME/.vim/words/cmake.txt

    " close loclists with buffer
    autocmd QuitPre * if empty(&buftype) | lclose | endif

    " remember state
    au BufWinLeave,BufWrite * silent! mkview
    au BufRead * silent! loadview
augroup END
