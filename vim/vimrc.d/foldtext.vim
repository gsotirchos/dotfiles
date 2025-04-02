function! MyFoldText()
    let first_line = getline(v:foldstart)
    let first_non_space_pos = match(first_line, '\S')
    let last_space_pos = max([0, first_non_space_pos  - 1])
    let fold_left_orig = substitute(first_line, '\(^\s*\S.\{,80}\S\)\%(\s.\{-}\)\=$', '\1', 'g')
    let leading_spaces = strpart(fold_left_orig, 0, last_space_pos + 1 - &shiftwidth)
    let num_dashes = &shiftwidth - 2
    let dashes = repeat('─', max([0, num_dashes]))
    let fold_left = leading_spaces . '└' . dashes . ' ' . strpart(fold_left_orig, first_non_space_pos)
    let fold_right = substitute(getline(v:foldend), '^\%(.\{-}\s*\)\=\(\S.\{,25}\)$', '\1', 'g')
    return (fold_left . ' ... ' . fold_right . '  (' . (v:foldend - v:foldstart + 1) . ' lines)')
endfunction
