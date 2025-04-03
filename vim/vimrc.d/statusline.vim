let s:MAX_PATH_LENGTH = 50
let s:HALF_NO_NAME_LENGTH = len('[No Name]') / 2

" Function to get the left-hand side content based on filetype
function! s:GetLeftSideContent()
    if (&filetype == 'qf')  " LocationList or QuickFix List
        return '%( %q%)'
    elseif (&filetype =~# '^.*preview.*$')  " Preview window
        return '%( %y%)'
    else
        return s:GetRegularEditorLeftSide()
    endif
endfunction

" Function to get the left-hand side content for regular editor windows
function! s:GetRegularEditorLeftSide()
    let filetype_field = '%( %{&filetype} %)'
    if !exists('b:git_info_cached')
        call s:UpdateGitInfoCache()
    endif
    if !exists('b:parent_path_cache')
        call s:UpdateParentPathCache()
    endif
    let git_info_field =  '%( %{b:git_info_cached} %)'
    let parent_path_field = s:GetParentDirectoryField()
    let file_name_field = '%t%m%a '
    let left_hand_side = filetype_field . git_info_field . parent_path_field . file_name_field
    return left_hand_side
endfunction

" Function to get parent directory information (path and its field)
function! s:GetParentDirectoryField()
    let filetype_field_length = empty(&filetype) ? 0 : len(" " . &filetype . " ")
    let git_info_field_length = empty(b:git_info_cached) ? 0 : len(" " . b:git_info_cached . " ")
    let half_name_length = max([1, float2nr(floor(len(expand("%:~:t")) / 2.0))])
    if (&filetype == '')
        let half_name_length = s:HALF_NO_NAME_LENGTH
    endif

    let path_field_length = s:CalculatePathFieldLength(filetype_field_length, git_info_field_length, half_name_length)
    let parent_path_field = '%<%-' . path_field_length . '( %{b:parent_path_cache}%)'
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
    " TODO: make it work for different directories
    " TODO: trim parens
    let b:git_info_cached = trim(system('__git_ps1 2> /dev/null'))
    if v:shell_error == 1
        let b:git_info_cached = '(git error)'
    endif
endfunction

" Function to store the current file's parent path
function! s:UpdateParentPathCache()
    if (&filetype == 'help')
        let b:parent_path_cache = ''
    else
        let b:parent_path_cache = substitute(expand('%:p:h'), expand('~'), '~', '') . '/'
    endif
endfunction

" Autocommand to update the Git info cache after saving the file
augroup GitInfoStatus
    autocmd! BufWinEnter,BufRead,BufWritePost * call s:UpdateGitInfoCache()
    autocmd! BufWinEnter,BufRead,BufWritePost * call s:UpdateParentPathCache()
augroup END

" Function to get the right-hand side content (line and column info)
function! s:GetRightSideContent()
    let lines_field = '%' . (b:numberwidth + 0) . '(%l%)/%-' . (b:numberwidth + 0) . '(%Ll%)'
    let columns_field = '%4(%c%)/%-5(' . len(getline(".")) . 'c%)'
    return '%=' . lines_field . columns_field
endfunction

" Main statusline function
function! MyStatusline()
    let left_hand_side = s:GetLeftSideContent()
    let right_hand_side = s:GetRightSideContent()
    return left_hand_side . right_hand_side
endfunction