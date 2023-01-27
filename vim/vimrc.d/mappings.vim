" disable ctrl-z
nnoremap <c-z> <nop>

" change leader
let mapleader =  ";"

" autocompletion mappings
inoremap <expr> <silent> <Up> pumvisible() ? "\<C-p>" : "\<C-o>gk"
inoremap <expr> <silent> <Down> pumvisible() ? "\<C-n>" : "\<C-o>gj"

" wrapped lines movement mappings
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
        return  "\"_cc"
    else
        return  "i"
    endif
endfunction
nnoremap <expr> i IndentWithI()

function! IndentWithA()
    if len(getline('.')) == 0
        return  "\"_cc"
    else
        return  "a"
    endif
endfunction
nnoremap <expr> a IndentWithA()

" use OS clipboard and copy-paste shortcuts
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

" swap p and P in visual mode
vnoremap p P
vnoremap P p

" toggle LocList
function! ToggleLocList()
    if get(getloclist(0, {'winid': 0}), 'winid', 0)
        "exec "set laststatus=" . g:laststatus
        lclose
    else
        exec "lopen " . winheight(0) / 3
        "let g:laststatus = &laststatus
        "if len(getbufinfo({'bufloaded': 1})) == 2
        "    set laststatus=0
        "endif
    endif
endfunction
nnoremap <silent> <leader>l :call ToggleLocList()<CR>

" toggle QuickFix
function! ToggleQuickFix()
    if get(getqflist({'winid': 0}), 'winid', 0)
        "exec "set laststatus=" . g:laststatus
        cclose
    else
        exec "copen " . winheight(0) / 3
        "let g:laststatus = &laststatus
        "if len(getbufinfo({'bufloaded': 1})) == 2
        "    set laststatus=0
        "endif
    endif
endfunction
nnoremap <silent> <leader>q :call ToggleQuickFix()<CR>

" toggle Preview
function! TogglePreview()
    for nr in range(1, winnr('$'))
        if getwinvar(nr, "&previewwindow") == 1
            pclose
            return
        endif
    endfor
    :ALEDetail
endfunction
nnoremap <silent> <leader>p :call TogglePreview()<CR>

" apply fixers
nnoremap <silent> <leader>f :ALEFix<CR>

" find-replace
nnoremap <leader>r :%s///g\|noh<Left><Left><Left><Left><Left><Left><Left>
vnoremap <leader>r :s///g\|noh<Left><Left><Left><Left><Left><Left><Left>

" case-insensitive searching using '\c'
noremap <silent> / :echo '/'<CR>/\c
noremap <silent> ? :echo '?'<CR>?\c

" show buffers list
nnoremap <leader>b :buffers<CR>:buffer<SPACE>

" other mappings
nnoremap o o<Esc>
nnoremap O O<Esc>
nnoremap <silent> <leader>d :ALEGoToDefinition \| new<CR>
