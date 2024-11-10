let g:NERDCompactSexyComs = 1

" execute script
nnoremap <buffer> <silent> <leader>x :w<return>:terminal python3 "%:p"<return>

" debug script
nnoremap <buffer> <silent> <leader>D :w<return>:terminal python3 -m pdb "%:p"<return>
