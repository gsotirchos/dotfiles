let g:NERDCompactSexyComs = 1

" execute script
nnoremap <silent> <leader>x :w<return>:terminal python3 "%:p"<return>

" debug script
nnoremap <silent> <leader>db :w<return>:terminal python3 -m pdb "%:p"<return>
