let b:NERDCompactSexyComs = 1

" execute script
nnoremap <silent> <buffer> <leader>x :w<return>:terminal python3 "%:p"<return>

" debug script
nnoremap <silent> <buffer> <leader>D :w<return>:terminal python3 -m pdb "%:p"<return>
