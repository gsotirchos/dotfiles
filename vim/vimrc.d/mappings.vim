" Change leader
let mapleader =  ';'

" Controllable mouse wheel scrolling
noremap  <ScrollWheelUp>     <C-y>
noremap  <S-ScrollWheelUp>   <C-y>
noremap  <ScrollWheelDown>   <C-e>
noremap  <S-ScrollWheelDown> <C-e>
inoremap <ScrollWheelUp>     <C-o><C-y>
inoremap <S-ScrollWheelUp>   <C-o><C-y>
inoremap <ScrollWheelDown>   <C-o><C-e>
inoremap <S-ScrollWheelDown> <C-o><C-e>

" Movement on wrapped lines
noremap  <silent> k       gk
noremap  <silent> j       gj
noremap  <silent> <Up>    gk
noremap  <silent> <Down>  gj
"inoremap <silent> <Up>    <C-o>gk
"inoremap <silent> <Down>  <C-o>gj
noremap  <silent> <Home>  g<Home>
noremap  <silent> <End>   g<End>
inoremap <silent> <Home>  <C-o>g<Home>
inoremap <silent> <End>   <C-o>g<End>
noremap  <silent> 0       g0
noremap  <silent> ^       g^
noremap  <silent> $       g$
noremap  <silent> <Space> za

" Movement in the autocompletion menu
inoremap <expr> <silent> <Up> pumvisible() ? "\<C-p>" : "\<C-o>gk"
inoremap <expr> <silent> <Down> pumvisible() ? "\<C-n>" : "\<C-o>gj"
inoremap <expr> <Return> pumvisible() ? "\<C-y>" : "\<C-g>u\<Return>"
inoremap <C-n> <C-x><C-u>

" Smart indenting when entering insert mode on empty lines
function! IndentWithI()
    if len(getline('.')) == 0
        return  "\"_cc"
    else
        return  "i"
    endif
endfunction
nnoremap <expr> i IndentWithI()
"
function! IndentWithA()
    if len(getline('.')) == 0
        return  "\"_cc"
    else
        return  "a"
    endif
endfunction
nnoremap <expr> a IndentWithA()

" Finding and replacing
nnoremap <leader>r :%s///cg\|noh<Left><Left><Left><Left><Left><Left><Left><Left>
vnoremap <leader>r :s///cg\|noh<Left><Left><Left><Left><Left><Left><Left><Left>

" Case-insensitive searching (with '\c')
noremap <silent> / :echo '/'<Return>/\c
noremap <silent> ? :echo '?'<Return>?\c

" Execute last command with Ctrl+Space
noremap  <silent> <C-Space> :@:<Return>
inoremap <silent> <C-Space> <Esc>:@:<Return>
cnoremap <silent> <C-Space> <C-e><C-u>@:<Return>

" Toggle LocList
function! ToggleLocList()
    if get(getloclist(0, {'winid': 0}), 'winid', 0)
        "exec 'set laststatus=' . g:laststatus
        lclose
    else
        let l:line_nr = line('.')
        exec 'lopen ' . winheight(0) / 3
        exec ':silent! /|' . l:line_nr . ' col'
        nohlsearch
        set cursorline
        "let g:laststatus = &laststatus
        "if len(getbufinfo({'bufloaded': 1})) == 2
        "    set laststatus=0
        "endif
    endif
endfunction
nnoremap <silent> <leader>l :call ToggleLocList()<Return>

" Toggle QuickFix
function! ToggleQuickFix()
    if get(getqflist({'winid': 0}), 'winid', 0)
        "exec 'set laststatus=' . g:laststatus
        cclose
    else
        exec 'copen ' . winheight(0) / 3
        "let g:laststatus = &laststatus
        "if len(getbufinfo({'bufloaded': 1})) == 2
        "    set laststatus=0
        "endif
    endif
endfunction
nnoremap <silent> <leader>q :call ToggleQuickFix()<Return>

" Toggle Preview
function! TogglePreview()
    for nr in range(1, winnr('$'))
        if getwinvar(nr, '&previewwindow') == 1
            pclose
            return
        endif
    endfor
    :ALEDetail
endfunction
nnoremap <silent> <leader>p :call TogglePreview()<Return>

" Show buffers list
nnoremap <leader>b :buffers<Return>:buffer<SPACE>

" Use OS clipboard and copy-paste shortcuts
if has('unnamedplus')
    set clipboard=unnamed,unnamedplus
else
    set clipboard=unnamed
endif
"inoremap <D-v> <Space><ESC>"+gPi<Delete>
"inoremap <D-v> <C-r>+
"nnoremap <D-v> "+p
"vnoremap <D-v> "+p
"cnoremap <D-v> <C-r>+
"vnoremap <D-c> "+y

" Print highlight group under cursor
map <F10> :echo
\   'hi<' . synIDattr(synID(line('.'),col('.'),1),'name') . '> ' .
\   'trans<' . synIDattr(synID(line('.'),col('.'),0),'name') . '> ' .
\   'lo<' . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . '>'
\   <Return>

" Disable Ctrl+z
nnoremap <C-z> <Nop>

" Shift+Tab is Ctrl+O in normal mode
nnoremap <S-Tab> <C-o>
nnoremap <C-o>   <Nop>

" Shift selected lines with Tab and Shift+Tab in visual mode
vnoremap <Tab>   >gv
vnoremap <S-Tab> <gv
vnoremap >       <Nop>
vnoremap <       <Nop>

" Swap p and P in visual mode
vnoremap p P
vnoremap P p

" other mappings
nnoremap Q <Nop>
nnoremap o o<Esc>
nnoremap O O<Esc>
nnoremap <leader>F :ALEFix<Return>
nnoremap <leader>f :ALEFindReferences -relative<Return>
nnoremap <leader>d :ALEGoToDefinition<Return>
nnoremap <leader>t :ALEGoToTypeDefinition<Return>
nnoremap <leader>i :ALEGoToImplementation<Return>
nnoremap <leader>Q :close<Return>
