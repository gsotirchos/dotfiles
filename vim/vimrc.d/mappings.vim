" disable ctrl-z
nnoremap <c-z> <nop>

" change leader
let mapleader =  ";"

" autocompletion mappings
"inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
"inoremap <expr> <C-p> pumvisible() ? "\<Up>" : ""
"inoremap <expr> <C-n> pumvisible() ? "\<Down>" : ""
inoremap <expr> <buffer> <silent> <Up> pumvisible() ? "\<C-p>" : "\<C-o>gk"
inoremap <expr> <buffer> <silent> <Down> pumvisible() ? "\<C-n>" : "\<C-o>gj"

" wrapped lines movement mappings
noremap  <buffer> <silent> <Up>    gk
noremap  <buffer> <silent> <Down>  gj
noremap  <buffer> <silent> k       gk
noremap  <buffer> <silent> j       gj
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
"nnoremap <D-v> "+p
"vnoremap <D-v> "+p
"cnoremap <D-v> <C-r>+
"vnoremap <D-c> "+y
"nnoremap <D-c> :echo "ok"

" toggle LocList
function! ToggleLocList()
    if get(getloclist(0, {'winid':0}), 'winid', 0)
        lclose
    else
        lopen
    endif
endfunction
nnoremap <silent> <leader>l :call ToggleLocList()<CR>

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

" case-insensitive searching using '\c'
noremap <silent> / :echo '/'<CR>/\c
noremap <silent> ? :echo '?'<CR>?\c

" other mappings
nnoremap o o<Esc>
nnoremap O O<Esc>
nnoremap <silent> <leader>d :ALEGoToDefinition \| new<CR>

