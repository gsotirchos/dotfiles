scriptencoding utf-8

function! s:UpdateSyntax(num_lines)
    if a:num_lines >= 2000
        syntax sync maxlines=2000
        setlocal redrawtime=10000
    else
        syntax sync fromstart
        "setlocal redrawtime=2000
    endif
endfunction

function! s:GetGutterWidth(bufnr)
    let l:sc = getbufvar(a:bufnr, '&signcolumn')
    if l:sc ==# 'no'
        return 0
    elseif l:sc ==# 'yes'
        return 2
    elseif l:sc ==# 'auto'
        if exists('*sign_getplaced')
            let l:placed = sign_getplaced(a:bufnr, {'group': '*'})
            if !empty(l:placed) && !empty(l:placed[0].signs)
                return 2
            endif
        endif
    endif
    return 0
endfunction

function! s:UpdateSignColumn(file_name, is_modifiable)
    if empty(a:file_name) || !a:is_modifiable
        setlocal signcolumn=no
    else
        setlocal signcolumn=auto
    endif
endfunction

function! s:UpdateLayout()
    let b:numberwidth = 1 + float2nr(ceil(log10(line('$') + 1)))
    let b:gutterwidth = s:GetGutterWidth(bufnr('%'))
    let l:max_width = get(g:, 'maxwinwidth', 80)
    let &l:textwidth = min([l:max_width, winwidth(0)]) - b:gutterwidth - &number * b:numberwidth - 1
    let &l:sidescrolloff = winwidth('%') / 2
endfunction

function! s:UpdateBreakindentopt()
    let &breakindentopt = 'shift:' . (&sw - 1)
endfunction

function! s:UpdateIndentGuides()
    let &l:listchars = &g:listchars . ',leadmultispace: ' . repeat(repeat(' ', &sw - 1) . '│', 8)
endfunction

augroup vimrc
    " clear existing definitions in this group
    autocmd!

    " enable sign column (when appropriate), set textwidth, set wrapping indent
    autocmd BufWinEnter,BufRead,BufWrite *
        \ call s:UpdateBreakindentopt()
        \|call s:UpdateSyntax(line('$'))
        \|call s:UpdateSignColumn(@%, &modifiable)

    autocmd BufWinEnter,BufRead,TextChanged,TextChangedI,VimResized *
        \ call s:UpdateLayout()

    autocmd User ALELintPost,ALEFixPost
        \ call s:UpdateLayout()

    " enable syntax
    autocmd Colorscheme * nested
        \ if !exists('g:syntax_on')
            \|syntax on
        \|endif
        "\|syntax enable

    " for non-text files: load default syntax, show guides, use easytags
    let s:NonCodeFiletypes = ['lisp', 'netrw', 'vimwiki', 'markdown', 'org', 'qf', 'conf', 'help', 'tex', 'latex', 'text', '']
    autocmd Colorscheme,BufWinEnter *
        \ if index(s:NonCodeFiletypes, &filetype) < 0
            \|runtime after/syntax/default.vim
            \|setlocal nospell
        \|endif
        \|call s:UpdateIndentGuides()
    autocmd OptionSet shiftwidth
        \ call s:UpdateBreakindentopt()
        \|call s:UpdateIndentGuides()

    " Check and sync theme (and re-enable colorscheme if syntax is lost) when gaining focus
    autocmd FocusGained * nested call s:CheckSystemTheme()

    " autosave named files
    autocmd CursorHold,FocusGained,FocusLost ?* nested
        \ if empty(&buftype) && &modified
            \|silent! update
        \|endif

    autocmd BufWinEnter,BufRead,BufWritePre ?*
        \ silent! let &fileencoding = 'utf-8'

    " treat certain extensions as XML
    autocmd BufWinEnter,BufRead,BufWritePre
        \ *.sdf,*.world,*.model,*.xacro,*.launch,*.plist
        \ set ft=xml

    " treat certain ROS configuration files as conf files
    autocmd BufWinEnter,BufRead,BufWritePre
        \ *.msg,*.srv,*.action
        \ set ft=conf

    " treat certain extensions as Lisp files
    "autocmd BufWinEnter,BufRead,BufWritePre
    "    \ *.lisp*.el,*.emacs
    "    \ set ft=lisp

    autocmd BufWinEnter,BufRead,BufWritePre
        \ *.vcg,*.dconf
        \ set ft=dosini

    autocmd BufWinEnter,BufRead,BufWritePre
        \ *.yml,*.rviz,*.env
        \ set ft=yaml

    " treat .m files as Matlab files
    autocmd BufWinEnter,BufRead,BufWritePre
        \ *.m
        \ set ft=matlab

    " use bash highlighting for def and sh filetypes
    autocmd FileType def,sh
        \ set syn=bash

    autocmd BufEnter *
        \ if winnr('$') == 1 && &buftype == 'quickfix'
            \| quit
        \| endif

    " close loclists with buffer
    autocmd QuitPre *
        \ if empty(&buftype)
            \|lclose
        \|endif

    autocmd BufWinLeave ?* mkview
    autocmd BufWinEnter * silent! loadview
augroup END


" Callbacks for Theme check jobs
function! s:ThemeOutCallback(channel, msg) dict
    call add(self.stdout, a:msg)
endfunction

function! s:ThemeExitCallback(job, status) dict
    let l:is_dark = 0

    if has('macunix')
        " On macOS, exit code 0 means dark mode, non-zero means light mode
        let l:is_dark = (a:status == 0)
    else
        " On generic Unix, we check the captured stdout
        let l:output = join(self.stdout, "\n")
        if l:output =~? 'dark' || l:output =~? '1'
            let l:is_dark = 1
        else
            let l:is_dark = 0
        endif
    endif

    let l:current_mode = l:is_dark ? 'dark' : 'light'
    if &background !=# l:current_mode || !exists('g:syntax_on')
        let &background = l:current_mode
        colorscheme sunyata
    endif
endfunction

function! s:CheckSystemTheme() abort
    if has('gui_running')
        return
    endif

    " Cancel existing theme check job if running
    let l:old_job = get(s:, 'theme_job', '')
    if !empty(l:old_job)
        silent! call job_stop(l:old_job)
        let s:theme_job = ''
    endif

    if has('job') && has('channel')
        if has('macunix')
            let l:cmd = ['defaults', 'read', '-g', 'AppleInterfaceStyle']
        elseif has('unix')
            let l:cmd = ['/bin/sh', '-c', 'gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null || dbus-send --print-reply --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:"org.freedesktop.appearance" string:"color-scheme" 2>/dev/null']
        else
            return
        endif

        let l:ctx = {
            \ 'stdout': [],
            \ }
        let l:job = job_start(l:cmd, {
            \ 'out_cb': function('s:ThemeOutCallback', l:ctx),
            \ 'exit_cb': function('s:ThemeExitCallback', l:ctx),
            \ })
        if job_status(l:job) ==# 'run'
            let s:theme_job = l:job
        endif
    else
        " Fallback for older Vim versions without async support
        let l:is_dark = 0
        if has('macunix')
            let l:mode = system('defaults read -g AppleInterfaceStyle 2>/dev/null')
            let l:is_dark = (v:shell_error == 0)
        elseif has('unix')
            let l:mode = system('gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null')
            if v:shell_error || empty(l:mode)
                let l:mode = system('dbus-send --print-reply --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:"org.freedesktop.appearance" string:"color-scheme" 2>/dev/null')
            endif
            if l:mode =~? 'dark' || l:mode =~? '1'
                let l:is_dark = 1
            else
                let l:is_dark = 0
            endif
        endif

        let l:current_mode = l:is_dark ? 'dark' : 'light'
        if &background !=# l:current_mode || !exists('g:syntax_on')
            let &background = l:current_mode
            colorscheme sunyata
        endif
    endif
endfunction

" Setup periodic check (if Vim supports timers)
if has('timers') && !exists('s:theme_timer_id')
    let s:theme_timer_id = timer_start(5000, {-> s:CheckSystemTheme()}, {'repeat': -1})
endif

" Run theme check immediately on startup
call s:CheckSystemTheme()
