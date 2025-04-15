" TODO: add check here
let g:wiki_root = $HOME . '/Library/Mobile Documents/iCloud~md~obsidian/Documents/Vaults/Wiki'
let g:wiki_zotero_root = $HOME . '/Zotero'
let g:wiki_global_load = 0
let g:wiki_completion_enabled = 0

let g:wiki_mappings_global = {
    \ 'n_<Plug>(wiki-link-next)': '<A-]>',
    \ 'n_<Plug>(wiki-link-prev)': '<A-[>',
    \ 'n_<Plug>(wiki-journal-prev)': '<A-}>',
    \ 'n_<Plug>(wiki-journal-next)': '<A-{>',
\}

" useful list management plugins
" - https://github.com/lervag/lists.vim
" - https://github.com/aserebryakov/vim-todo-lists
