function! s:GetRightSideContent(winid, bufnr)
    let l:numberwidth = getbufvar(a:bufnr, 'numberwidth', 0)
    let lines_field = ' %' . (l:numberwidth + 0) . '(L%l%)/%-' . (l:numberwidth + 0) . '(%L%)'

    let l:lnum = a:winid > 0 ? line('.', a:winid) : line('.')
    let l:line = get(getbufline(a:bufnr, l:lnum), 0, '')
    let columns_field = '%4(C%c%)/%-4(' . len(l:line) . '%)'

    let l:SLFileInfoHL = getbufvar(a:bufnr, 'SLFileInfoHL', '')
    return '%=' . l:SLFileInfoHL . lines_field . columns_field . '%*'
endfunction

function! s:GetLeftSideContent(winid, bufnr)
    let l:filetype = getbufvar(a:bufnr, '&filetype')
    let l:buftype = getbufvar(a:bufnr, '&buftype')
    let l:SLFileInfoHL = getbufvar(a:bufnr, 'SLFileInfoHL', '')
    if (l:filetype =~# '^.*preview.*$')  " Preview window
        return l:SLFileInfoHL . '%( %Y %)%*'
    elseif (l:filetype == 'qf')  " LocationList or QuickFix List
        return l:SLFileInfoHL . ' %q %*'
    elseif (l:filetype == 'netrw')  " netrw window
        return l:SLFileInfoHL . '%( %Y %)%*'
    elseif (l:buftype ==# 'terminal')  " Terminal window
        return l:SLFileInfoHL . '%( %t %)%*'
    else
        return s:GetRegularEditorLeftSide(a:winid, a:bufnr)
    endif
endfunction

function! s:GetRegularEditorLeftSide(winid, bufnr)
    let filetype_field = '%( %Y %)'
    if empty(getbufvar(a:bufnr, 'parent_path_cached', ''))
        call s:UpdateParentPathCache(a:bufnr)
    endif
    let git_info_field =  '%( %{get(g:, "coc_git_status", "")} %)'
    let parent_path_field = s:GetParentDirectoryField(a:winid, a:bufnr)
    let file_name_field = '%t%m%a '

    let l:SLFileInfoHL = getbufvar(a:bufnr, 'SLFileInfoHL', '')
    let l:SLGitInfoHL = getbufvar(a:bufnr, 'SLGitInfoHL', '')
    let l:SLFilePathHL = getbufvar(a:bufnr, 'SLFilePathHL', '')
    let l:SLFileNameHL = getbufvar(a:bufnr, 'SLFileNameHL', '')

    let left_hand_side = l:SLFileInfoHL . filetype_field . l:SLGitInfoHL . git_info_field . l:SLFilePathHL .  parent_path_field . l:SLFileNameHL . file_name_field . '%*'
    return left_hand_side
endfunction

function! s:GetParentDirectoryField(winid, bufnr)
    let l:path_field_length = s:CalculatePathFieldLength(a:winid, a:bufnr)
    let l:parent_path_cached = getbufvar(a:bufnr, 'parent_path_cached', '')
    let parent_path_field = '%( '. s:FormatField(l:parent_path_cached, l:path_field_length) . '%)'
    return parent_path_field
endfunction

function! s:CalculatePathFieldLength(winid, bufnr)
    let l:filetype = getbufvar(a:bufnr, '&filetype')
    let l:filetype_field_length = empty(l:filetype) ? 0 : len(' ' . l:filetype . ' ')
    let l:git_info_field_length = !exists("g:coc_git_status") ? 0 : len(' ' . get(g:, 'coc_git_status', '') . ' ')

    if (l:filetype == '')
        let l:half_name_length = len('[No Name]') / 2
    else
        let l:filename = fnamemodify(bufname(a:bufnr), ':t')
        let l:half_name_length = max([1, float2nr(floor(len(l:filename) / 2.0))])
    endif
    return max([0, winwidth(a:winid) / 2 - l:filetype_field_length - l:git_info_field_length - l:half_name_length - 1])
endfunction

function! s:FormatField(str, max_len)
    if a:max_len <= 4
        return ""
    endif
    let l:str = a:str
    if len(l:str) > a:max_len
        let l:keep_len = a:max_len - 1
        let l:start_len = float2nr(floor(l:keep_len / 2.0))
        let l:end_len = l:keep_len - l:start_len
        let l:start_part = a:str[: l:start_len - 1]
        let l:end_part = a:str[len(a:str) - l:end_len :]
        let l:str = l:start_part . '…' . l:end_part
    elseif len(l:str) < a:max_len
        let l:padding_len = a:max_len - len(l:str)
        let l:str .= repeat(' ', l:padding_len)
    endif
    return l:str
endfunction

function! s:UpdateParentPathCache(...)
    let l:bufnr = a:0 > 0 ? a:1 : bufnr('%')
    let l:filetype = getbufvar(l:bufnr, '&filetype')
    let l:buftype = getbufvar(l:bufnr, '&buftype')
    if (l:filetype == 'help' || l:buftype ==# 'terminal')
        call setbufvar(l:bufnr, 'parent_path_cached', '')
        call setbufvar(l:bufnr, 'full_parent_path_cached', '')
    else
        let l:path = fnamemodify(bufname(l:bufnr), ':p:h')
        let l:short_path = substitute(l:path, expand('~'), '~', '') . '/'
        call setbufvar(l:bufnr, 'parent_path_cached', l:short_path)
        call setbufvar(l:bufnr, 'full_parent_path_cached', resolve(l:path))
    endif
endfunction

function! s:SetFocusedColors()
    let b:SLFileInfoHL = '%#SLFileInfo#'
    let b:SLFilePathHL = '%#SLFilePath#'
    let b:SLFileNameHL = '%#SLFileName#'
    let b:SLGitInfoHL = '%#SLGitInfo#'
endfunction

function! s:SetUnfocusedColors()
    let b:SLFileInfoHL = '%#SLFileInfoNC#'
    let b:SLFilePathHL = '%#SLFilePathNC#'
    let b:SLFileNameHL = '%#SLFileNameNC#'
    let b:SLGitInfoHL = '%#SLGitInfoNC#'
endfunction

function! MyStatusLine()
    let l:winid = get(g:, 'statusline_winid', win_getid())
    let l:bufnr = winbufnr(l:winid)
    let left_hand_side = s:GetLeftSideContent(l:winid, l:bufnr)
    let right_hand_side = s:GetRightSideContent(l:winid, l:bufnr)
    return left_hand_side . right_hand_side
endfunction

augroup statusline
    autocmd!
    autocmd! BufReadPost,BufWrite *
        \ call s:UpdateParentPathCache()
    autocmd! BufEnter,BufWinEnter,FocusGained *
        \ call s:SetFocusedColors()
        \|setlocal statusline=%!MyStatusLine()
    autocmd! BufLeave,FocusLost *
        \ call s:SetUnfocusedColors()
        \|setlocal statusline=%!MyStatusLine()
augroup END
