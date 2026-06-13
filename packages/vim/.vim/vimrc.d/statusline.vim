scriptencoding utf-8

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
    elseif (l:filetype ==# 'qf')  " LocationList or QuickFix List
        return l:SLFileInfoHL . ' %q %*'
    elseif (l:filetype ==# 'netrw')  " netrw window
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

    if (l:filetype ==# '')
        let l:half_name_length = len('[No Name]') / 2
    else
        let l:filename = fnamemodify(bufname(a:bufnr), ':t')
        let l:half_name_length = max([1, float2nr(floor(len(l:filename) / 2.0))])
    endif
    return max([0, winwidth(a:winid) / 2 - l:filetype_field_length - l:git_info_field_length - l:half_name_length - 1])
endfunction

function! s:FormatField(str, max_len)
    if a:max_len <= 4
        return ''
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
    if (l:filetype ==# 'help' || l:buftype ==# 'terminal')
        call setbufvar(l:bufnr, 'parent_path_cached', '')
        call setbufvar(l:bufnr, 'full_parent_path_cached', '')
    else
        let l:path = fnamemodify(bufname(l:bufnr), ':p:h')
        let l:short_path = substitute(l:path, expand('~'), '~', '') . '/'
        call setbufvar(l:bufnr, 'parent_path_cached', l:short_path)
        call setbufvar(l:bufnr, 'full_parent_path_cached', resolve(l:path))
    endif
endfunction

" Function to parse git status command output lines and cache the result
function! s:ParseGitStatusOutput(bufnr, lines)
    if empty(a:lines)
        call setbufvar(a:bufnr, 'git_info_cached', '')
        return
    endif

    let l:branch_line = a:lines[0]
    " Check if the first line starts with '## '
    if l:branch_line !~# '^##'
        call setbufvar(a:bufnr, 'git_info_cached', '')
        return
    endif
    
    let l:branch_line = l:branch_line[3:]

    let l:branch = ''
    let l:diff_info = ''

    " Look for ahead/behind info inside [...]
    let l:bracket_idx = stridx(l:branch_line, '[')
    if l:bracket_idx != -1
        let l:brackets = l:branch_line[l:bracket_idx + 1 : len(l:branch_line) - 2] " strip [ and ]
        let l:ahead = 0
        let l:behind = 0
        let l:ahead_match = matchlist(l:brackets, 'ahead \(\d\+\)')
        if !empty(l:ahead_match)
            let l:ahead = str2nr(l:ahead_match[1])
        endif
        let l:behind_match = matchlist(l:brackets, 'behind \(\d\+\)')
        if !empty(l:behind_match)
            let l:behind = str2nr(l:behind_match[1])
        endif
        
        if l:behind > 0
            let l:diff_info .= '>' . l:behind
        endif
        if l:ahead > 0
            let l:diff_info .= '<' . l:ahead
        endif
        if l:diff_info ==# ''
            let l:diff_info = '='
        endif
    else
        if g:statusline_git_upstream_enabled
            " Check if there is an upstream
            if stridx(l:branch_line, '...') != -1
                let l:diff_info = '='
            endif
        endif
    endif

    " Extract branch name
    let l:branch_part = l:branch_line
    let l:dot_idx = stridx(l:branch_part, '...')
    if l:dot_idx != -1
        let l:branch_part = l:branch_part[: l:dot_idx - 1]
    endif
    let l:space_idx = stridx(l:branch_part, ' ')
    if l:space_idx != -1
        let l:branch_part = l:branch_part[: l:space_idx - 1]
    endif
    let l:branch = trim(l:branch_part)

    let l:git_info = ''
    if l:branch !=# '' && l:branch !=# 'HEAD'
        let l:git_info .= ' ' . l:branch
    else
        call setbufvar(a:bufnr, 'git_info_cached', '')
        return
    endif

    " Get status indicators (staged, unstaged, untracked)
    let l:staged_changes = 0
    let l:unstaged_changes = 0
    let l:untracked_files = 0
    for l:line in a:lines[1:]
        if l:line =~# '^[MADRC]'
            let l:staged_changes += 1
        elseif l:line =~# '^.[MD]'
            if l:line !~# '^[MADRC].'
                let l:unstaged_changes += 1
            endif
        elseif l:line =~# '^??'
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
        let l:status_indicators .= '?'
    endif
    let l:git_info .= l:status_indicators

    " Append ahead/behind diff info
    let l:git_info .= l:diff_info
    let l:git_info .= ' '

    call setbufvar(a:bufnr, 'git_info_cached', l:git_info)
endfunction

" Callbacks for Vim jobs
function! s:VimOutCallback(channel, msg) dict
    call add(self.stdout, a:msg)
endfunction

function! s:VimCloseCallback(channel) dict
    let l:job = ch_getjob(a:channel)
    " Ensure the job has finished exiting so we can read its exit code
    let l:limit = 50
    while job_status(l:job) !=# 'dead' && l:limit > 0
        sleep 5m
        let l:limit -= 1
    endwhile
    let l:exitval = job_info(l:job).exitval

    if l:exitval == 0
        call setbufvar(self.bufnr, 'is_git_repo', 1)
        call s:ParseGitStatusOutput(self.bufnr, self.stdout)
    else
        call setbufvar(self.bufnr, 'is_git_repo', 0)
        call setbufvar(self.bufnr, 'git_info_cached', '')
    endif
    execute 'redrawstatus!'
endfunction

" Function to actually fetch all Git info for the current file asynchronously
function! s:UpdateGitInfoCache(bufnr)
    if !get(g:, 'statusline_git_enabled', 1)
        call setbufvar(a:bufnr, 'git_info_cached', '')
        return
    endif

    " Only run on loaded files with valid paths
    let l:filepath = resolve(expand('#' . a:bufnr . ':p'))
    if l:filepath ==# ''
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

    let l:upstream_flag = get(g:, 'statusline_git_upstream_enabled', 0) ? '' : ' --no-ahead-behind'
    let l:cmd = ['git', '-C', l:filedir, 'status', '--porcelain', '--branch']
    if !get(g:, 'statusline_git_upstream_enabled', 0)
        call add(l:cmd, '--no-ahead-behind')
    endif

    " Cancel existing job if running
    let l:old_job = getbufvar(a:bufnr, 'git_job', '')
    if !empty(l:old_job)
        silent! call job_stop(l:old_job)
        call setbufvar(a:bufnr, 'git_job', '')
    endif

    if has('job') && has('channel')
        let l:ctx = {
            \ 'bufnr': a:bufnr,
            \ 'stdout': [],
            \ }
        let l:job = job_start(l:cmd, {
            \ 'out_cb': function('s:VimOutCallback', l:ctx),
            \ 'close_cb': function('s:VimCloseCallback', l:ctx),
            \ })
        if job_status(l:job) ==# 'run'
            call setbufvar(a:bufnr, 'git_job', l:job)
        endif
    else
        " Fallback for older Vim versions without async support
        let l:git_command_prefix = 'git -C "' . escape(l:filedir, '"') . '" '
        let l:status_output = system(l:git_command_prefix . 'status --porcelain --branch' . l:upstream_flag . ' 2> /dev/null')
        if v:shell_error != 0
            call setbufvar(a:bufnr, 'is_git_repo', 0)
            call setbufvar(a:bufnr, 'git_info_cached', '')
            return
        endif
        call setbufvar(a:bufnr, 'is_git_repo', 1)
        let l:lines = split(l:status_output, '\n')
        call s:ParseGitStatusOutput(a:bufnr, l:lines)
    endif
endfunction

" Function to get the cached Git info for the current file
function! s:GetGitInfoField(bufnr)
    let l:cached = getbufvar(a:bufnr, 'git_info_cached', -1)
    if l:cached is -1
        " Set it to empty string first to avoid infinite recursion / repeated calls
        call setbufvar(a:bufnr, 'git_info_cached', '')
        call s:UpdateGitInfoCache(a:bufnr)
        return ''
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
augroup END

if !exists('g:statusline_git_enabled')
    let g:statusline_git_enabled = 1
endif
if !exists('g:statusline_git_upstream_enabled')
    let g:statusline_git_upstream_enabled = 0
endif
if !exists('g:statusline_git_profile')
    let g:statusline_git_profile = 0
endif

function! ToggleGitStatus()
    let g:statusline_git_enabled = get(g:, 'statusline_git_enabled', 1) ? 0 : 1
    if g:statusline_git_enabled
        echo 'Git status in statusline: ENABLED'
        for l:buf in range(1, bufnr('$'))
            if bufexists(l:buf)
                call setbufvar(l:buf, 'git_info_cached', -1)
            endif
        endfor
    else
        echo 'Git status in statusline: DISABLED'
        for l:buf in range(1, bufnr('$'))
            if bufexists(l:buf)
                call setbufvar(l:buf, 'git_info_cached', '')
            endif
        endfor
    endif
    redrawstatus!
endfunction

function! ToggleGitUpstream()
    let g:statusline_git_upstream_enabled = get(g:, 'statusline_git_upstream_enabled', 0) ? 0 : 1
    if g:statusline_git_upstream_enabled
        echo 'Git ahead/behind check in statusline: ENABLED'
    else
        echo 'Git ahead/behind check in statusline: DISABLED'
    endif
    for l:buf in range(1, bufnr('$'))
        if bufexists(l:buf)
            call setbufvar(l:buf, 'git_info_cached', -1)
        endif
    endfor
    redrawstatus!
endfunction

function! ToggleGitProfile()
    let g:statusline_git_profile = get(g:, 'statusline_git_profile', 0) ? 0 : 1
    if g:statusline_git_profile
        echo 'Git status profiling: ENABLED (logs will appear in :messages)'
    else
        echo 'Git status profiling: DISABLED'
    endif
endfunction

command! ToggleGitStatus call ToggleGitStatus()
command! ToggleGitUpstream call ToggleGitUpstream()
command! ToggleGitProfile call ToggleGitProfile()
