function! MyStatusline()
    if (&ft == 'qf')
        " LocationList or QuickFix List
        let left_hand_side = '%( %q%)'
    elseif (&ft =~# '^.*preview.*$')
        " Preview window
        let left_hand_side = '%( %y%)'
    else
        " Regular editor
        let left_hand_side = '%( %y%)'

        if (&ft == '')
            " let parent_dir = getcwd() . '/'
            let parent_dir = substitute(expand('%:p:h'), expand('~'), '~', '') . '/'
            let filetype_field_length = 0
            let half_name_length = 5  " len('[No Name]') / 2
        else
            if (&ft == 'help')
                let parent_dir = ''
            else
                let parent_dir = expand("%:~:h") . '/'
            endif

            let filetype_field_length = len(" [" . &ft . "]")  " <- len(' %y')
            let half_name_length = max([1, float2nr(floor(len(expand("%:~:t")) / 2.0))])
        endif

        let path_field_length = max(
        \   [0, min([50, winwidth(0) / 2 - filetype_field_length - half_name_length])]
        \)  " use max 50 chars for path field
        let parent_dir_field = '%<%-' . path_field_length . '(' . parent_dir . '%)'
        let file_name_field = '%t%m%a   '
        let left_hand_side .= ' ' . parent_dir_field  . file_name_field
    endif
    let lines_field = '%' . (b:numberwidth + 0) . '(%l%)/%-' . (b:numberwidth + 0) . '(%Ll%)'
    let columns_field = '%4(%c%)/%-5(' . len(getline(".")) . 'c%)'
    return left_hand_side . '%=' . lines_field . columns_field
endfunction
