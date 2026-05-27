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


function! s:CheckSystemTheme() abort
    let l:is_dark = 0 " Default

    if !has('gui_running')
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
    endif

    let l:current_mode = l:is_dark ? 'dark' : 'light'
    if &background !=# l:current_mode || !exists('g:syntax_on')
        let &background = l:current_mode
        colorscheme sunyata
    endif
endfunction

" Setup periodic check (if Vim supports timers)
if has('timers') && !exists('s:theme_timer_id')
    let s:theme_timer_id = timer_start(5000, {-> s:CheckSystemTheme()}, {'repeat': -1})
endif
