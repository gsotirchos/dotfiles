function! s:GetRightSideContent()
    let lines_field = ' %' . (b:numberwidth + 0) . '(L%l%)/%-' . (b:numberwidth + 0) . '(%L%)'
    let columns_field = '%4(C%c%)/%-4(' . len(getline('.')) . '%)'
    return '%=' . b:SLFileInfoHL . lines_field . columns_field . '%*'
endfunction

function! s:GetLeftSideContent()
    if (&filetype =~# '^.*preview.*$')  " Preview window
        return b:SLFileInfoHL . '%( %Y %)%*'
    elseif (&filetype == 'qf')  " LocationList or QuickFix List
        return b:SLFileInfoHL . ' %q %*'
    elseif (&filetype == 'netrw')  " Preview window
        return b:SLFileInfoHL . '%( %Y %)%*'
    elseif (&buftype ==# 'terminal')  " Terminal window
        return b:SLFileInfoHL . '%( %t %)%*'
    else
        return s:GetRegularEditorLeftSide()
    endif
endfunction

function! s:GetRegularEditorLeftSide()
    let filetype_field = '%( %Y %)'
    if !exists('b:parent_path_cached')
        call s:UpdateParentPathCache()
    endif
    let git_info_field =  '%( %{get(g:, "coc_git_status", "")} %)'
    let parent_path_field = s:GetParentDirectoryField()
    let file_name_field = '%t%m%a '
    let left_hand_side = b:SLFileInfoHL . filetype_field . b:SLGitInfoHL . git_info_field . b:SLFilePathHL .  parent_path_field . b:SLFileNameHL . file_name_field . '%*'
    return left_hand_side
endfunction

function! s:GetParentDirectoryField()
    let l:path_field_length = s:CalculatePathFieldLength()
    let parent_path_field = '%( '. s:FormatField(b:parent_path_cached, l:path_field_length) . '%)'
    return parent_path_field
endfunction

function! s:CalculatePathFieldLength()
    let l:filetype_field_length = empty(&filetype) ? 0 : len(' ' . &filetype . ' ')
    let l:git_info_field_length = empty(get(g:, 'coc_git_status', '')) ? 0 : len(' ' . g:coc_git_status . ' ')
    if (&filetype == '')
        let l:half_name_length = len('[No Name]') / 2
    else
        let l:half_name_length = max([1, float2nr(floor(len(expand('%:t')) / 2.0))])
    endif
    return max([0, winwidth(0) / 2 - l:filetype_field_length - l:git_info_field_length - l:half_name_length - 1])
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

function! s:UpdateParentPathCache()
    if (&filetype == 'help' || &buftype ==# 'terminal')
        let b:parent_path_cached = ''
        let b:full_parent_path_cached = ''
    else
        let b:parent_path_cached = substitute(expand('%:p:h'), expand('~'), '~', '') . '/'
        let b:full_parent_path_cached = resolve(expand('%:p:h'))
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
    let left_hand_side = s:GetLeftSideContent()
    let right_hand_side = s:GetRightSideContent()
    return left_hand_side . right_hand_side
endfunction

augroup statusline
    autocmd!
    autocmd! BufReadPost,BufWrite *
        \ call s:UpdateParentPathCache()
    autocmd! BufEnter,BufWinEnter,FocusGained *
        \ call s:SetFocusedColors()
        \|setlocal statusline=%{%MyStatusLine()%}
    autocmd! BufLeave,FocusLost *
        \ call s:SetUnfocusedColors()
        \|setlocal statusline=%{%MyStatusLine()%}
augroup END
