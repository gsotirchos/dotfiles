let s:MAX_PATH_LENGTH = 50
let s:HALF_NO_NAME_LENGTH = len('[No Name]') / 2
let s:GIT_INFO_UPDATE_TIMEOUT = 5
let s:times_left_to_update_git_info = 0

" Function to get the right-hand side content (line and column info)
function! s:GetRightSideContent()
    let lines_field = '%' . (b:numberwidth + 0) . '(%l%)/%-' . (b:numberwidth + 0) . '(%LL%)'
    let columns_field = '%4(%c%)/%-5(' . len(getline('.')) . 'C%)'
    return '%=' . b:SLFileInfo . lines_field . columns_field . '%*'
endfunction

" Function to get the left-hand side content based on filetype
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

" Function to get the left-hand side content for regular editor windows
function! s:GetRegularEditorLeftSide()
    let filetype_field = '%( %Y %)'
    if !exists('b:parent_path_cached')
        call s:UpdateParentPathCache()
    endif
    let b:git_info_cached = exists('b:git_info_cached') ? b:git_info_cached : ''
    let git_info_field =  '%( %{b:git_info_cached} %)'
    let parent_path_field = s:GetParentDirectoryField()
    let file_name_field = '%t%m%a '
    let left_hand_side = b:SLFileInfo . filetype_field . b:SLGitInfo . git_info_field . b:SLFilePath .  parent_path_field . b:SLFileName . file_name_field . '%*'
    return left_hand_side
endfunction

" Function to get parent directory information (path and its field)
function! s:GetParentDirectoryField()
    let filetype_field_length = empty(&filetype) ? 0 : len(' ' . &filetype . ' ')
    let git_info_field_length = empty(b:git_info_cached) ? 0 : len(' ' . b:git_info_cached . ' ')
    let half_name_length = max([1, float2nr(floor(len(expand('%:~:t')) / 2.0))])
    if (&filetype == '')
        let half_name_length = s:HALF_NO_NAME_LENGTH
    endif

    let path_field_length = s:CalculatePathFieldLength(filetype_field_length, git_info_field_length, half_name_length)
    let parent_path_field = '%<%-' . path_field_length . '( %{b:parent_path_cached}%)'
    return parent_path_field
endfunction

" Function to calculate the path field length
function! s:CalculatePathFieldLength(filetype_field_length, git_info_field_length, half_name_length)
    return max([
    \   0,
    \   min([
    \       s:MAX_PATH_LENGTH,
    \       winwidth(0) / 2 - a:filetype_field_length - a:git_info_field_length - a:half_name_length])
    \ ])
endfunction

" Function to actually fetch all Git info for the current file
function! s:UpdateGitInfoCache()
    if !exists('b:git_info_cached')
        call s:UpdateParentPathCache()
    endif
    let git_ps1_string = trim(system('IN_VIM=true source ~/.dotfiles/etc/set_git_ps1.sh && cd ' . b:full_parent_path_cached . ' && __git_ps1 2> /dev/null'))
    if v:shell_error == 0
        let b:git_info_cached = slice(substitute(git_ps1_string, ' ', '', ''), 1, -1)
    else
        let b:git_info_cached = ''
    endif
endfunction

" Function to store the current file's parent path
function! s:UpdateParentPathCache()
    if (&filetype == 'help' || &buftype ==# 'terminal')
        let b:parent_path_cached = ''
        let b:full_parent_path_cached = ''
    else
        let b:parent_path_cached = substitute(expand('%:p:h'), expand('~'), '~', '') . '/'
        let b:full_parent_path_cached = resolve(expand('%:p:h'))
    endif
endfunction

function! s:SetColors()
    let b:SLFileInfo = '%#SLFileInfo#'
    let b:SLFilePath = '%#SLFilePath#'
    let b:SLFileName = '%#SLFileName#'
    let b:SLGitInfo = '%#SLGitInfo#'
endfunction

function! s:UnsetColors()
    let b:SLFileInfo = '%#SLFileInfoNC#'
    let b:SLFilePath = '%#SLFilePathNC#'
    let b:SLFileName = '%#SLFileNameNC#'
    let b:SLGitInfo = '%#SLGitInfoNC#'
endfunction

augroup statusline
    autocmd!
    autocmd! BufReadPost,BufWrite *
    \   call s:UpdateParentPathCache()
    \|  let s:times_left_to_update_git_info -= 1
    \|  if s:times_left_to_update_git_info <= 0
    \|      call s:UpdateGitInfoCache()
    \|      let s:times_left_to_update_git_info = s:GIT_INFO_UPDATE_TIMEOUT
    \|  endif
    autocmd! BufEnter,BufWinEnter,FocusGained *
    \   call s:SetColors()
    \|  setlocal statusline=%{%MyStatusline()%}
    autocmd! BufLeave,FocusLost *
    \   call s:UnsetColors()
    \|  setlocal statusline=%{%MyStatusline()%}
    \|  call s:UpdateGitInfoCache()
augroup END

" Main statusline function
function! MyStatusline()
    let left_hand_side = s:GetLeftSideContent()
    let right_hand_side = s:GetRightSideContent()
    return left_hand_side . right_hand_side
endfunction