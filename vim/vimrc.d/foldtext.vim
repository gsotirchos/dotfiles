function! s:FoldText()
    let l:fold_left = substitute(getline(v:foldstart), '\%(^\s*\)\=\(\S.\{,50}\S\)\%(\s.\{-}\)\=$', '\1', 'g')
    let l:fold_right = substitute(getline(v:foldend), '^\%(.\{-}\s*\)\=\(\S.\{,25}\)$', '\1', 'g')
    let l:fold_prefix = s:GetFoldPrefix()
    let l:folded_lines_count = (v:foldend - v:foldstart + 1)
    return l:fold_prefix . l:fold_left . ' ... ' . l:fold_right . '  (' . l:folded_lines_count . ' lines)'
endfunction

function! s:GetFoldPrefix()
    let l:first_line = getline(v:foldstart)
    let l:first_non_space_pos = match(l:first_line, '\S')
    let l:last_leading_char_pos = max([0, l:first_non_space_pos - &shiftwidth])
    let b:leadmultispace = s:GetLeadMultispace()
    if len(b:leadmultispace) == 0
        let l:fold_lead_chars = strpart(l:first_line, 0, l:last_leading_char_pos, v:true)
    elseif len(b:leadmultispace) >= l:last_leading_char_pos
        let l:fold_lead_chars = strpart(b:leadmultispace, 0, l:last_leading_char_pos, v:true)
    elseif len(b:leadmultispace) < l:last_leading_char_pos
        let l:padding_length = l:last_leading_char_pos - len(b:leadmultispace)
        let l:fold_lead_chars = b:leadmultispace . repeat(' ', l:padding_length)
    endif
    let l:fold_dashes = repeat('─', max([0, &shiftwidth - 2]))
    let l:fold_char = s:NestLevelDecreased() ? '└' : '├'
    return l:fold_lead_chars . l:fold_char . l:fold_dashes . ' '
endfunction

function! s:GetLeadMultispace()
    if exists('b:leadmultispace')
        return b:leadmultispace
    endif
    let l:listchars_pairs = split(&listchars, ',')
    for l:pair in l:listchars_pairs
        let l:split_pair = split(l:pair, ':')
        if l:split_pair[0] == 'leadmultispace'
            return l:split_pair[1]
        endif
    endfor
    return ''
endfunction

function! s:NestLevelDecreased()
    return match(getline(v:foldstart - 1), '\S') - match(getline(v:foldend + 1), '\S') > 0
endfunction

set foldtext=s:FoldText()
