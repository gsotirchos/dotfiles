function! SetSyntax(num_lines)
    if a:num_lines >= 2000
        syntax sync maxlines=2000
        set redrawtime=10000
    else
        syntax sync fromstart
        "set redrawtime=2000
    endif
endfunction

function! SetSignColumn(file_name, is_modifiable)
    "if empty(a:file_name) || !a:is_modifiable
        let &signcolumn = 'no'
        let b:gutterwidth = 0
    "elseif (&signcolumn =~ '')
    "    let &signcolumn = 'yes'
    "    let b:gutterwidth = 2
    "endif
endfunction

augroup vimrc
    " clear existing definitions in this group
    autocmd!

    " enable sign column (when appropriate), set textwidth, set wrapping indent
    autocmd BufWinEnter,BufRead,BufWrite,VimResized *
    \   call SetSyntax(line('$'))
    \|  call SetSignColumn(@%, &modifiable)
    \|  let b:numberwidth = 1 + float2nr(ceil(log10(line("$") + 1)))
    \|  let &textwidth = min([maxwinwidth, winwidth(0)]) - b:gutterwidth - &number * b:numberwidth - 1
    \|  let &breakindentopt = "shift:" . (&ts-1)
    \|  let &sidescrolloff = winwidth('%') / 2

    " autosave named files
    autocmd CursorHold ?* nested if empty(&buftype) | update | endif

    " always convert to utf-8
    autocmd BufWinEnter,BufRead,BufWritePost ?* silent! set fileencoding=utf-8

    " don't spell-check help or QuickFix/LocList buffers
    autocmd FileType help,qf set nospell

    " enable syntax;
    autocmd Colorscheme *
    \   if !exists("g:syntax_on")
    \|      syntax on
    \|  endif
    \|  syntax enable

    " for non-text files: load default syntax, show guides, use easytags
    let textFiletypes = ['markdown', 'qf', 'help', 'tex', 'latex', 'text', 'yaml', '']
    autocmd Colorscheme,BufWinEnter *
    \   if index(textFiletypes, &filetype) < 0
    \|      runtime after/syntax/default.vim
    \|      runtime after/syntax/indent_guides.vim
    \|      let b:easytags_auto_update = 1
    \|  endif

    " re-enable colorscheme (and syntax) when gaining back focus
    autocmd FocusGained * nested
    \   if !exists("g:syntax_on")
    \|      colorscheme sunyata
    \|  endif

    " disable syntax when losing focus
    "autocmd FocusLost * syntax off

    autocmd BufWinEnter,BufRead,BufWritePost *
    \   set statusline=%{%MyStatusline()%}

    " treat certain extensions as XML
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.sdf,*.world,*.model,*.xacro,*.config,*.launch,*.plist
    \   set ft=xml

    " treat certain ROS configuration files as conf files
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.msg,*.srv,*.action
    \   set ft=conf

    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.vcg,*.dconf
    \   set ft=dosini

    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.yml,*.rviz,*.env
    \   set ft=yaml

    " treat .def and .sh files as bash files
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.def,*.bash,*.sh
    \   set ft=bash

    " treat .m files as Matlab files
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.m
    \   set ft=matlab

    " treat C files as C++ files
    autocmd FileType c set ft=cpp

    " use custom CMake autocompletion
    autocmd BufWinEnter,BufRead,BufWritePost
    \   CMakeLists.txt,*.cmake
    \   set complete=.,k
    \|  set dictionary=$HOME/.vim/words/cmake.txt

    " close loclists with buffer
    autocmd QuitPre * if empty(&buftype) | lclose | endif

    " remember buffer state
    autocmd BufWinLeave * silent! mkview
    autocmd BufWinEnter * silent! loadview
augroup END
