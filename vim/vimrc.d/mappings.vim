" change leader
let mapleader =  ";"

" autocompletion mappings
"inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"inoremap <expr> <C-n> pumvisible() ? "\<Down>" : ""
inoremap <expr> <C-j> pumvisible() ? "" :  "\<C-j>"
"inoremap <expr> <C-p> pumvisible() ? "\<Up>" : ""
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
"nnoremap <D-v>  "+p
"vnoremap <D-v>  "+p
"cnoremap <D-v> <C-r>+
"vnoremap <D-c>  "+y
"nnoremap <D-c>  :echo "ok"

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
nnoremap o o<Esc>
nnoremap O O<Esc>
nnoremap <silent> <leader>d :ALEGoToDefinition \| new<CR>

