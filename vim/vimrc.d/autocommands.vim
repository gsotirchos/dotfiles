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
    autocmd BufWinEnter,BufRead,BufWrite *
    \   call SetSyntax(line('$'))
    \|  call SetSignColumn(@%, &modifiable)

    autocmd BufWinEnter,BufRead,TextChanged,TextChangedI,VimResized *
    \   let b:numberwidth = 1 + float2nr(ceil(log10(line('$') + 1)))
    \|  let b:gutterwidth = exists('b:gutterwidth') ? b:gutterwidth : 0
    \|  let &textwidth = min([maxwinwidth, winwidth(0)]) - b:gutterwidth - &number * b:numberwidth - 1
    \|  let &breakindentopt = 'shift:' . (&ts-1)
    \|  let &sidescrolloff = winwidth('%') / 2

    " enable syntax
    autocmd Colorscheme *
    \   if !exists('g:syntax_on')
    \|      syntax on
    \|  endif
    \|  syntax enable

    " for non-text files: load default syntax, show guides, use easytags
    let textFiletypes = ['markdown', 'qf', 'conf', 'help', 'tex', 'latex', 'text', 'yaml', '']
    autocmd Colorscheme,BufWinEnter *
    \   if index(textFiletypes, &filetype) < 0
    \|      runtime after/syntax/default.vim
    \|      runtime after/syntax/indent_guides.vim
    \|      if exists(':HighlightTags')
    \|          HighlightTags
    \|      endif
    \|  endif

    " re-enable colorscheme (and syntax) when gaining back focus
    autocmd FocusGained * nested
    \   if !exists('g:syntax_on')
    \|      colorscheme sunyata
    \|  endif

    " disable syntax when losing focus
    "autocmd FocusLost * syntax off

    " autosave named files
    autocmd CursorHold,FocusGained,FocusLost ?* nested
    \   if empty(&buftype) && &modified
    \|      update
    \|  endif

    autocmd BufWinEnter,BufRead,BufWritePre ?*
    \   silent! let &fileencoding = 'utf-8'
    \ | let b:easytags_file = $HOME . '/.vim/tags/' . substitute(slice(expand('%:p'), 1), '/', '.', 'g') . '.tags'
    \|  let &tags = b:easytags_file

    " treat certain extensions as XML
    autocmd BufWinEnter,BufRead,BufWritePre
    \   *.sdf,*.world,*.model,*.xacro,*.launch,*.plist
    \   set ft=xml

    " treat certain ROS configuration files as conf files
    autocmd BufWinEnter,BufRead,BufWritePre
    \   *.msg,*.srv,*.action
    \   set ft=conf

    autocmd BufWinEnter,BufRead,BufWritePre
    \   *.vcg,*.dconf
    \   set ft=dosini

    autocmd BufWinEnter,BufRead,BufWritePre
    \   *.yml,*.rviz,*.env
    \   set ft=yaml

    " treat .m files as Matlab files
    autocmd BufWinEnter,BufRead,BufWritePre
    \   *.m
    \   set ft=matlab

    " use custom CMake autocompletion
    autocmd Filetype cmake
    \   set complete=.,k
    \|  set dictionary=$HOME/.vim/words/cmake.txt

    " don't spell-check help or QuickFix/LocList buffers
    autocmd FileType help,qf
    \   set nospell

    " use bash highlighting for def and sh filetypes
    autocmd FileType def,sh
    \   set syn=bash

    " use C++ highlighting for C files
    autocmd FileType c
    \   set syn=cpp

    " close loclists with buffer
    autocmd QuitPre *
    \   if empty(&buftype)
    \|      lclose
    \|  endif

    " remember buffer state
    autocmd BufWinLeave * silent! mkview
    autocmd BufWinEnter * silent! loadview
augroup END
