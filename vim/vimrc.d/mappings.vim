" Change leader
let mapleader =  ';'

" Controllable mouse wheel scrolling
noremap  <silent> <ScrollWheelUp>     <C-y>
noremap  <silent> <S-ScrollWheelUp>   <C-y>
noremap  <silent> <ScrollWheelDown>   <C-e>
noremap  <silent> <S-ScrollWheelDown> <C-e>
inoremap <silent> <ScrollWheelUp>     <C-o><C-y>
inoremap <silent> <S-ScrollWheelUp>   <C-o><C-y>
inoremap <silent> <ScrollWheelDown>   <C-o><C-e>
inoremap <silent> <S-ScrollWheelDown> <C-o><C-e>

" Movement on wrapped lines
noremap  <silent> k       gk
noremap  <silent> j       gj
noremap  <silent> <Up>    gk
noremap  <silent> <Down>  gj
noremap  <silent> <Home>  g<Home>
noremap  <silent> <End>   g<End>
inoremap <silent> <Up>    <C-o>gk
inoremap <silent> <Down>  <C-o>gj
inoremap <silent> <Home>  <C-o>g<Home>
inoremap <silent> <End>   <C-o>g<End>
inoremap <silent> <C-u>   <C-g>u<C-u>
inoremap <silent> <C-w>   <C-g>u<C-w>
noremap  <silent> 0       g0
noremap  <silent> ^       g^
noremap  <silent> $       g$

" Movement in the autocompletion menu
"inoremap <silent> <C-n> <C-x><C-u>
"inoremap <silent> <expr> <Up> pumvisible() ? "\<C-p>" : "\<C-o>gk"
"inoremap <silent> <expr> <Down> pumvisible() ? "\<C-n>" : "\<C-o>gj"
"inoremap <silent> <expr> <Return> pumvisible() ? "\<C-y>" : "\<C-g>u\<Return>"
"inoremap <silent> <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<C-Tab>"
"inoremap <silent> <expr> <C-z> pumvisible() ? "\<C-x>\<C-z>" : "\<Plug>(copilot-dismiss)"
"inoremap <silent> <expr> <C-l>
"\    empty(copilot#GetDisplayedSuggestion().text) ?
"\        "\<Plug>(copilot-suggest)" :
"\        "\<Plug>(copilot-next)"

" Smart indenting when entering insert mode on empty lines
nnoremap <expr> i IndentWithI()
nnoremap <expr> a IndentWithA()
function! IndentWithI()
    if len(getline('.')) == 0
        return  "\"_cc"
    else
        return  "i"
    endif
endfunction
function! IndentWithA()
    if len(getline('.')) == 0
        return  "\"_cc"
    else
        return  "a"
    endif
endfunction

" Search documentation for the word under cursor
nnoremap <silent> <Leader>h :call ShowDocumentation()<Return>
function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

" Case-insensitive searching (with '\c')
nnoremap <silent> / :echo '/'<Return>/\c
nnoremap <silent> ? :echo '?'<Return>?\c

" Search & replace word under cursor/selected
nnoremap <silent> <Leader>rr
\    :echo 'replace `' . expand('<cword>') . '` with: _'<Return>
\    :%s///cg\|noh<Home><Right><Right><Right>\<<C-R><C-W>\><Right>
vnoremap <silent> <Leader>rr
\    "wy:echo 'replace `' . getreg('w') . '` with: _'<Return>
\    :%s///cg\|noh<Home><Right><Right><Right>\<<C-R>w\><Right>

" Replace expression
nnoremap <Leader>RR :%s///cg\|noh<Home><Right><Right><Right>
vnoremap <Leader>RR :s///cg\|noh<Home><Right><Right><Right><Right><Right><Right><Right>

" Clear highlighted search
nnoremap <Leader>n :noh<Return>

" Re-execute last command with Ctrl+Space
nnoremap <silent> <C-Space> :@:<Return>
inoremap <silent> <C-Space> <Esc>:@:<Return>
cnoremap <silent> <C-Space> <C-e><C-u>@:<Return>

" Toggle LocList
nnoremap <silent> <Leader>l :call ToggleLocList()<Return>
function! ToggleLocList()
    if get(getloclist(0, {'winid': 0}), 'winid', 0)
        lclose
    else
        let l:loclist_win_height = winheight(0) / 3
        let l:line_nr = line('.')
        if !exists('l:coc_diagnostics_opened')
            if exists(':CocDiagnostics')
                :CocDiagnostics
                let l:coc_diagnostics_opened = v:true
            endif
        endif
        exec 'lopen ' . l:loclist_win_height
        exec ':silent! /|' . l:line_nr . ' col'
        nohlsearch
        set cursorline
    endif
endfunction

" Toggle QuickFix
nnoremap <silent> <Leader>q :call ToggleQuickFix()<Return>
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

" Toggle Preview
nnoremap <silent> <Leader>p :call TogglePreview()<Return>
function! TogglePreview()
    for nr in range(1, winnr('$'))
        if getwinvar(nr, '&previewwindow') == 1
            pclose
            return
        endif
    endfor
    if exists(':ALEDetail')
        :ALEDetail
        return
    endif
endfunction

" Show buffers list
nnoremap <Leader>b :buffers<Return>:buffer<Space>

" Clipboard copying/pasting
"inoremap <D-v> <Space><ESC>"+gPi<Delete>
"inoremap <D-v> <C-r>+
"nnoremap <D-v> "+p
"vnoremap <D-v> "+p
"cnoremap <D-v> <C-r>+
"vnoremap <D-c> "+y

" Print highlight group under cursor
nnoremap <F10> :echo
\   'hi<' . synIDattr(synID(line('.'),col('.'),1),'name') . '> ' .
\   'trans<' . synIDattr(synID(line('.'),col('.'),0),'name') . '> ' .
\   'lo<' . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . '>'
\   <Return>

" Shift+Tab is Ctrl+O in normal mode
nnoremap <silent> <S-Tab> <C-o>
nnoremap <silent> <C-o>   <Nop>

" Shift selected lines with Tab and Shift+Tab in visual mode
vnoremap <silent> <Tab>   >gv
vnoremap <silent> <S-Tab> <gv
noremap  <silent> >       <Nop>
noremap  <silent> <       <Nop>

" Swap p and P in visual mode
vnoremap p P
vnoremap P p

" Other mappings
noremap <C-z> <Nop>
noremap <C-]> <Nop>
nnoremap <Leader>Q :close<Return>
nnoremap <silent> o o<Esc>
nnoremap <silent> O O<Esc>
nnoremap <silent> <Space> za
"nnoremap <Leader>F :ALEFix<Return>
"nnoremap <Leader>f :ALEFindReferences -relative<Return>
"nnoremap <Leader>d :ALEGoToDefinition<Return>
"nnoremap <Leader>t :ALEGoToTypeDefinition<Return>
"nnoremap <Leader>i :ALEGoToImplementation<Return>

runtime vimrc.d/coc_mappings.vim
