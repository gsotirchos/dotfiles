function! MyFoldText()
    let l:first_line = getline(v:foldstart)
    let l:first_non_space_pos = match(l:first_line, '\S')
    let l:last_space_pos = max([0, l:first_non_space_pos  - 1])
    let l:fold_left_orig = substitute(l:first_line, '\(^\s*\S.\{,80}\S\)\%(\s.\{-}\)\=$', '\1', 'g')
    let l:leading_spaces = strpart(l:fold_left_orig, 0, l:last_space_pos + 1 - &shiftwidth)
    let l:num_dashes = &shiftwidth - 2
    let l:dashes = repeat('─', max([0, l:num_dashes]))
    let l:fold_char = len(getline(v:foldend + 1)) == 0 ? '└' : '├'
    let l:fold_left =
        \ l:leading_spaces . l:fold_char . l:dashes . ' '
        \ . strpart(l:fold_left_orig, l:first_non_space_pos)
    let l:fold_right = substitute(getline(v:foldend), '^\%(.\{-}\s*\)\=\(\S.\{,25}\)$', '\1', 'g')
    return l:fold_left . ' ... ' . l:fold_right . '  (' . (v:foldend - v:foldstart + 1) . ' lines)'
endfunction

set foldtext=MyFoldText()
