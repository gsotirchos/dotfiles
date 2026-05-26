function! s:GetRightSideContent(winid, bufnr)
    let l:numberwidth = getbufvar(a:bufnr, 'numberwidth', 0)
    let lines_field = ' %' . (l:numberwidth + 0) . '(L%l%)/%-' . (l:numberwidth + 0) . '(%L%)'

    let l:lnum = a:winid > 0 ? line('.', a:winid) : line('.')
    let l:line = get(getbufline(a:bufnr, l:lnum), 0, '')
    let columns_field = '%4(C%c%)/%-4(' . len(l:line) . '%)'

    let l:SLFileInfoHL = getbufvar(a:bufnr, 'SLFileInfoHL', '')
    return l:SLFileInfoHL . '%=' . lines_field . columns_field . '%*'
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
    let l:SLFileInfoHL = getbufvar(a:bufnr, 'SLFileInfoHL', '')
    let l:SLGitInfoHL = getbufvar(a:bufnr, 'SLGitInfoHL', '')
    let l:SLFilePathHL = getbufvar(a:bufnr, 'SLFilePathHL', '')
    let l:SLFileNameHL = getbufvar(a:bufnr, 'SLFileNameHL', '')

    let l:git_info = s:GetGitInfoField(a:bufnr)
    let git_info_field = empty(l:git_info) ? '' : l:SLGitInfoHL . ' ' . l:git_info . ' '
    let parent_path_field = s:GetParentDirectoryField(a:winid, a:bufnr)
    let file_name_field = '%t%m%a '

    let left_hand_side = l:SLFileInfoHL . filetype_field . git_info_field . l:SLFilePathHL .  parent_path_field . l:SLFileNameHL . file_name_field . '%*'
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
    let l:git_info_field_length = len(s:GetGitInfoField(a:bufnr))

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

" Function to actually fetch all Git info for the current file
function! s:UpdateGitInfoCache(bufnr)
    " Only run on loaded files with valid paths
    let l:filepath = resolve(expand('#' . a:bufnr . ':p'))
    if l:filepath == ''
        call setbufvar(a:bufnr, 'git_info_cached', '')
        call setbufvar(a:bufnr, 'is_git_repo', 0)
        return
    endif

    let l:filedir = fnamemodify(l:filepath, ':h')

    " Check and cache if we are inside a Git repo (Performance Optimization #1)
    if getbufvar(a:bufnr, 'is_git_repo', -1) == 0
        call setbufvar(a:bufnr, 'git_info_cached', '')
        return
    endif

    let l:git_command_prefix = 'git -C "' . escape(l:filedir, '"') . '" '

    " If we haven't checked for Git repository yet, check now
    if getbufvar(a:bufnr, 'is_git_repo', -1) == -1
        call system(l:git_command_prefix . 'rev-parse --is-inside-work-tree 2> /dev/null')
        if v:shell_error != 0
            call setbufvar(a:bufnr, 'is_git_repo', 0)
            call setbufvar(a:bufnr, 'git_info_cached', '')
            return
        endif
            call setbufvar(a:bufnr, 'is_git_repo', 1)
    endif

    let l:git_info = ''

    " Get the current branch name
    let l:branch = trim(system(l:git_command_prefix . 'rev-parse --abbrev-ref HEAD 2> /dev/null'))
    if v:shell_error == 0 && l:branch != '' && l:branch != 'HEAD'
        let l:git_info .= ' ' . l:branch
    else
        call setbufvar(a:bufnr, 'git_info_cached', '')
        return
    endif

    " Get status indicators (staged, unstaged, untracked)
    let l:status = system(l:git_command_prefix . 'status --porcelain 2> /dev/null')
    let l:staged_changes = 0
    let l:unstaged_changes = 0
    let l:untracked_files = 0
    for l:line in split(l:status, '\n')
        if l:line =~ '^[MADRC]'
            let l:staged_changes += 1
        elseif l:line =~ '^.[MD]'
            if l:line !~ '^[MADRC].'
                let l:unstaged_changes += 1
            endif
        elseif l:line =~ '^??'
            let l:untracked_files += 1
        endif
    endfor

    let l:status_indicators = ''
    if l:unstaged_changes > 0
        let l:status_indicators .= '*'
    endif
    if l:staged_changes > 0
        let l:status_indicators .= '+'
    endif
    if l:untracked_files > 0
        let l:status_indicators .= '%%'
    endif
    let l:git_info .= l:status_indicators

    " Get commits ahead and behind remote
    let l:upstream = trim(system(l:git_command_prefix . 'rev-parse --verify --quiet @{upstream} 2> /dev/null'))
    if v:shell_error == 0
        let l:ahead = len(split(system(l:git_command_prefix . 'log --oneline HEAD..@{upstream} 2> /dev/null'), '\n')) - 1
        let l:behind = len(split(system(l:git_command_prefix . 'log --oneline @{upstream}..HEAD 2> /dev/null'), '\n')) - 1
        let l:diff_info = ''
        if l:ahead > 0
            let l:diff_info .= '>' . l:ahead
        endif
        if l:behind > 0
            let l:diff_info .= '<' . l:behind
        endif
        if l:diff_info == ''
            let l:diff_info = '='
        endif
        let l:git_info .= l:diff_info
    endif
    let l:git_info .= ' '

    call setbufvar(a:bufnr, 'git_info_cached', l:git_info)
endfunction

" Function to get the cached Git info for the current file
function! s:GetGitInfoField(bufnr)
    let l:cached = getbufvar(a:bufnr, 'git_info_cached', -1)
    if l:cached is -1
        call s:UpdateGitInfoCache(a:bufnr)
        return getbufvar(a:bufnr, 'git_info_cached', '')
    endif
    return l:cached
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
        \ call s:UpdateParentPathCache(str2nr(expand('<abuf>')))
        \|call s:UpdateGitInfoCache(str2nr(expand('<abuf>')))
    autocmd! BufEnter,BufWinEnter,FocusGained *
        \ call s:SetFocusedColors()
        \|setlocal statusline=%!MyStatusLine()
    autocmd! BufLeave,FocusLost *
        \ call s:SetUnfocusedColors()
        \|setlocal statusline=%!MyStatusLine()
        \|call s:UpdateGitInfoCache(str2nr(expand('<abuf>')))
augroup END
