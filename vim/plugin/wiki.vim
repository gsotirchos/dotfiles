if has('mac')
    let g:wiki_root = $HOME . '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vaults/Wiki'
else
    let g:wiki_root = $HOME . '/Documents/Obsidian/Wiki'
endif
call mkdir(g:wiki_root, 'p')
let g:wiki_zotero_root = $HOME . '/Zotero'
let g:wiki_global_load = 0
let g:wiki_completion_enabled = 0

let g:wiki_mappings_global = {
\   'n_<Plug>(wiki-link-next)': '<A-]>',
\   'n_<Plug>(wiki-link-prev)': '<A-[>',
\   'n_<Plug>(wiki-journal-prev)': '<A-}>',
\   'n_<Plug>(wiki-journal-next)': '<A-{>',
\}

augroup MyWikiAutocmds
autocmd!
autocmd User WikiBufferInitialized
\   let &l:path = substitute(expand(g:wiki_root), ' ', '\\ ', 'g')
augroup END

" useful list management plugins
" - https://github.com/lervag/lists.vim
" - https://github.com/aserebryakov/vim-todo-lists
