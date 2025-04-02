let s:MAX_PATH_LENGTH = 50
let s:HALF_NO_NAME_LENGTH = len('[No Name]') / 2

" Function to get the left-hand side content based on filetype
function! s:GetLeftSideContent()
    if (&ft == 'qf')
        return '%( %q%)' " LocationList or QuickFix List
    elseif (&ft =~# '^.*preview.*$')
        return '%( %y%)' " Preview window
    else
        return s:GetRegularEditorLeftSide()
    endif
endfunction

" Function to get the left-hand side content for regular editor windows
function! s:GetRegularEditorLeftSide()
    let filetype_field = '%( %{&filetype} %)'
    let git_info_field = s:GetGitInfoField()
    let parent_dir_field = s:GetParentDirectoryField(len(git_info_field))
    let file_name_field = '%t%m%a '
    let left_hand_side = filetype_field . git_info_field . parent_dir_field . file_name_field
    return left_hand_side
endfunction

" Function to get parent directory information (path and its field)
function! s:GetParentDirectoryField(git_info_field_length)
    "let parent_dir = expand("%:~:h") . '/'
    let parent_dir = substitute(expand('%:p:h'), expand('~'), '~', '') . '/'
    let filetype_field_length = len(" " . &ft . " ")
    let half_name_length = max([1, float2nr(floor(len(expand("%:~:t")) / 2.0))])
    if (&ft == '')
        let filetype_field_length -= len(" " . " ")
        let half_name_length = s:HALF_NO_NAME_LENGTH
    elseif (&ft == 'help')
        let parent_dir = ''
    endif

    let path_field_length = s:CalculatePathFieldLength(filetype_field_length, a:git_info_field_length, half_name_length)
    let parent_dir_field = ' %<%-' . path_field_length . '(' . parent_dir . '%)'
    return parent_dir_field
endfunction

" Function to calculate the path field length
function! s:CalculatePathFieldLength(filetype_field_length, git_info_field_length, half_name_length)
    return max([
    \   0,
    \   min([
    \       s:MAX_PATH_LENGTH,
    \       winwidth(0) / 2 - a:filetype_field_length - a:git_info_field_length - a:half_name_length - 1])
    \ ])
endfunction

" Function to actually fetch all Git info for the current file
function! s:UpdateGitInfoCache()
    " Resolve symlinks to get the path of the real file
    let filepath = resolve(expand('%:p'))

    if filepath == ''
        let b:git_info_cached = ''
        return
    endif
    let filedir = fnamemodify(filepath, ':h')
    let git_command_prefix = 'git -C "' . escape(filedir, '"') . '" '
    let git_info = ''

    " Get the current branch
    let branch = trim(system(git_command_prefix . 'rev-parse --abbrev-ref HEAD 2> /dev/null'))
    if v:shell_error == 0 && branch != '' && branch != 'HEAD'
        let git_info .= ' ' . branch
    else
        let b:git_info_cached = ''
        return
    endif

    " Get status information (staged, unstaged, untracked)
    let status = system(git_command_prefix . 'status --porcelain 2> /dev/null')
    let staged_changes = 0
    let unstaged_changes = 0
    let untracked_files = 0
    for line in split(status, '\n')
        if line =~ '^[MADRC]'
            let staged_changes += 1
        elseif line =~ '^.[MD]'
            " Need to exclude cases where the file is also staged (e.g., 'MM')
            if line !~ '^[MADRC].'
                let unstaged_changes += 1
            endif
        elseif line =~ '^??'
            let untracked_files += 1
        endif
    endfor

    let status_indicators = ''
    if unstaged_changes > 0
        let status_indicators .= '*'
    endif
    if staged_changes > 0
        let status_indicators .= '+'
    endif
    if untracked_files > 0
        let status_indicators .= '%%'
    endif
    let git_info .= status_indicators

    " Get commits ahead and behind the remote
    let diff_info = ''
    let upstream = trim(system(git_command_prefix . 'rev-parse --verify --quiet @{upstream} 2> /dev/null'))
    if v:shell_error == 0
        let ahead = trim(system(git_command_prefix . 'rev-list --count @{upstream}..HEAD 2> /dev/null'))
        let behind = trim(system(git_command_prefix . 'rev-list --count HEAD..@{upstream} 2> /dev/null'))
        let diff_info = ''
        if ahead > 0
            let diff_info .= '>' . ahead
        endif
        if behind > 0
            let diff_info .= '<' . behind
        endif
        if diff_info == ''
            let diff_info = '='
        endif
        "let diff_prefix = (git_info != '' || status_indicators != '') ? '(' : '('
        "let diff_suffix = ')'
        "let diff_info = diff_prefix . diff_info . diff_suffix
    endif
    let git_info .= diff_info
    let git_info .= ' '

    let b:git_info_cached = git_info
endfunction

" Function to get the cached Git info for the current file
function! s:GetGitInfoField()
    if !exists('b:git_info_cached')
        " Initialize the cache on first call (e.g., when the buffer is loaded)
        call s:UpdateGitInfoCache()
    endif
    return b:git_info_cached
endfunction

" Autocommand to update the Git info cache after saving the file
augroup GitInfoStatus
    autocmd! FocusLost * call s:UpdateGitInfoCache()
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