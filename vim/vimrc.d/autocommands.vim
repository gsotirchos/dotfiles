function! s:SetSyntax(num_lines)
    if a:num_lines >= 2000
        syntax sync maxlines=2000
        set redrawtime=10000
    else
        syntax sync fromstart
        "set redrawtime=2000
    endif
endfunction

function! s:SetSignColumn(file_name, is_modifiable)
    "if empty(a:file_name) || !a:is_modifiable
        let &signcolumn = 'no'
        let b:gutterwidth = 0
    "elseif (&signcolumn =~ '')
    "    let &signcolumn = 'yes'
    "    let b:gutterwidth = 2
    "endif
endfunction

function! s:UpdateIndentGuides()
    let &l:listchars = &g:listchars . ',leadmultispace: ' . repeat(repeat(' ', &sw - 1) . '│', 5)
endfunction

augroup vimrc
    " clear existing definitions in this group
    autocmd!

    " enable sign column (when appropriate), set textwidth, set wrapping indent
    autocmd BufWinEnter,BufRead,BufWrite *
        \ call s:SetSyntax(line('$'))
        \|call s:SetSignColumn(@%, &modifiable)

    autocmd BufWinEnter,BufRead,TextChanged,TextChangedI,VimResized *
        \ let b:numberwidth = 1 + float2nr(ceil(log10(line('$') + 1)))
        \|let b:gutterwidth = exists('b:gutterwidth') ? b:gutterwidth : 0
        \|let &textwidth = min([maxwinwidth, winwidth(0)]) - b:gutterwidth - &number * b:numberwidth - 1
        \|let &breakindentopt = 'shift:' . (&ts-1)
        \|let &sidescrolloff = winwidth('%') / 2

    " enable syntax
    autocmd Colorscheme * nested
        \ if !exists('g:syntax_on')
            \|syntax on
        \|endif
        "\|syntax enable

    " for non-text files: load default syntax, show guides, use easytags
    let s:NonCodeFiletypes = ['netrw', 'vimwiki', 'markdown', 'qf', 'conf', 'help', 'tex', 'latex', 'text', '']
    autocmd Colorscheme,BufWinEnter *
        \ if index(s:NonCodeFiletypes, &filetype) < 0
            \|runtime after/syntax/default.vim
            \|setlocal nospell
        \|endif
        \|call s:UpdateIndentGuides()
    autocmd OptionSet shiftwidth
        \ call s:UpdateIndentGuides()

    " re-enable colorscheme (and syntax) when gaining back focus
    autocmd FocusGained * nested
        \ if !exists('g:syntax_on')
            \|colorscheme sunyata
        \|endif

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

    " close loclists with buffer
    autocmd QuitPre *
        \ if empty(&buftype)
            \|lclose
        \|endif

    autocmd BufWinLeave * silent! mkview
    autocmd BufWinEnter * silent! loadview
augroup END
