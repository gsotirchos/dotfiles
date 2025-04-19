let s:MAX_PATH_LENGTH = 50
let s:HALF_NO_NAME_LENGTH = len('[No Name]') / 2

function! s:GetRightSideContent()
    let lines_field = ' %' . (b:numberwidth + 0) . '(L%l%)/%-' . (b:numberwidth + 0) . '(%L%)'
    let columns_field = '%4(C%c%)/%-4(' . len(getline('.')) . '%)'
    return '%=' . b:SLFileInfo . lines_field . columns_field . '%*'
endfunction

function! s:GetLeftSideContent()
    if (&filetype == 'qf')  " LocationList or QuickFix List
        return b:SLFileInfo . ' %q %*'
    elseif (&filetype =~# '^.*preview.*$')  " Preview window
        return b:SLFileInfo . '%( %Y %)%*'
    elseif (&buftype ==# 'terminal')  " Terminal window
        return b:SLFileInfo . '%( %t %)%*'
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
    let left_hand_side = b:SLFileInfo . filetype_field . b:SLGitInfo . git_info_field . b:SLFilePath .  parent_path_field . b:SLFileName . file_name_field . '%*'
    return left_hand_side
endfunction

function! s:GetParentDirectoryField()
    let filetype_field_length = empty(&filetype) ? 0 : len(' ' . &filetype . ' ')
    let git_info_field_length = empty(get(g:, 'coc_git_status', '')) ? 0 : len(' ' . g:coc_git_status . ' ')
    let half_name_length = max([1, float2nr(floor(len(expand('%:~:t')) / 2.0))])
    if (&filetype == '')
        let half_name_length = s:HALF_NO_NAME_LENGTH
    endif

    let path_field_length = s:CalculatePathFieldLength(filetype_field_length, git_info_field_length, half_name_length)
    let parent_path_field = '%<%-' . path_field_length . '( %{b:parent_path_cached}%)'
    return parent_path_field
endfunction

function! s:CalculatePathFieldLength(filetype_field_length, git_info_field_length, half_name_length)
    return max([
        \0,
        \min([
            \s:MAX_PATH_LENGTH,
            \winwidth(0) / 2 - a:filetype_field_length - a:git_info_field_length - a:half_name_length])
        \])
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
    let b:SLFileInfo = '%#SLFileInfo#'
    let b:SLFilePath = '%#SLFilePath#'
    let b:SLFileName = '%#SLFileName#'
    let b:SLGitInfo = '%#SLGitInfo#'
endfunction

function! s:SetUnfocusedColors()
    let b:SLFileInfo = '%#SLFileInfoNC#'
    let b:SLFilePath = '%#SLFilePathNC#'
    let b:SLFileName = '%#SLFileNameNC#'
    let b:SLGitInfo = '%#SLGitInfoNC#'
endfunction

function! MyStatusline()
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
        \|setlocal statusline=%{%MyStatusline()%}
    autocmd! BufLeave,FocusLost *
        \ call s:SetUnfocusedColors()
        \|setlocal statusline=%{%MyStatusline()%}
augroup END
