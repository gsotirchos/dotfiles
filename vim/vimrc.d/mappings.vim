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

" Case-insensitive searching by default (using '\c')
nnoremap <silent> / :echo '/'<Return>/\c
nnoremap <silent> ? :echo '?'<Return>?\c

" Search & replace word under cursor/selection globally
nnoremap <silent> <Leader>rr
    \ :echo 'replace `' . expand('<cword>') . '` with: _'<Return>
    \:%s///cg\|noh<Home><Right><Right><Right>\(\<<C-R><C-W>\>\)<Right>
vnoremap <silent> <Leader>rr
    \ "wy:echo 'replace selection with: _'<Return>gv
    \:<BS><BS><BS><BS><BS>%s///cg\|noh<Home><Right><Right><Right>\(<C-R>w\)<Right>

" Search & replace globally
nnoremap <Leader>R :%s///cg\|noh<Home><Right><Right><Right>
vnoremap <Leader>R :s///cg\|noh<Home><Right><Right><Right><Right><Right><Right><Right>

" Clear highlighted search
nnoremap <silent> <Leader>n :noh<Return>

" Show buffers list
nnoremap <Leader>b :buffers<Return>:buffer<Space>

" Search documentation for the word under cursor
nnoremap <silent> <Leader>h :call ShowDocumentation()<Return>
function! ShowDocumentation()
    if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
    else
        call feedkeys('K', 'in')
    endif
endfunction

" Toggle LocList
nnoremap <silent> <Leader>l :call ToggleLocList()<Return>
function! ToggleLocList()
    if get(getloclist(0, {'winid': 0}), 'winid', 0)
        lclose
    else
        let l:loclist_win_height = winheight(0) / 3
        let l:line_nr = line('.')
        if exists(':CocDiagnostics')
            if !exists('l:coc_diagnostics_opened')
                :CocDiagnostics
                let l:coc_diagnostics_opened = v:true
            endif
        endif
        exec 'lopen ' . l:loclist_win_height
        exec ':silent! /|' . l:line_nr . ' col'
        nohlsearch
    endif
endfunction

" Toggle QuickFix
nnoremap <silent> <Leader>q :call ToggleQuickFix()<Return>
function! ToggleQuickFix()
    if get(getqflist({'winid': 0}), 'winid', 0)
        cclose
    else
        exec 'copen ' . winheight(0) / 3
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

" Print highlight group under cursor
nnoremap <F10> :echo
    \'hi<' . synIDattr(synID(line('.'),col('.'),1),'name') . '> ' .
    \'trans<' . synIDattr(synID(line('.'),col('.'),0),'name') . '> ' .
    \'lo<' . synIDattr(synIDtrans(synID(line('.'),col('.'),1)),'name') . '>'
    \<Return>

" Re-execute last command with Ctrl+Space
nnoremap <silent> <C-Space> :@:<Return>

" Shift+Tab is Ctrl+O in normal mode
nnoremap <silent> <S-Tab> <C-o>
nnoremap <silent> <C-o>   <Nop>

" Shift selected lines with Tab and Shift+Tab in visual mode
vnoremap <silent> <Tab>   >gv
vnoremap <silent> <S-Tab> <gv
noremap  <silent> >       <Nop>
noremap  <silent> <       <Nop>
inoremap <silent> <S-Tab> <C-d>

" Swap p and P in visual mode (don't replace clipboard)
vnoremap p P
vnoremap P p

" Other mappings
nnoremap <silent> <Space> za
nnoremap <silent> <S-Space> zA
nnoremap <silent> o o<Esc>
nnoremap <silent> O O<Esc>
nnoremap Q     <Nop>
nnoremap <C-z> <Nop>
nnoremap <C-]> <Nop>
nnoremap <Leader>Q :close<Return>
command! -nargs=0 Q :q
