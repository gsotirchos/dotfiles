function! SetSignColumn(file_name, is_modifiable)
    if empty(a:file_name) || !a:is_modifiable
        let &signcolumn = 'no'
        let b:gutterwidth = 0
    elseif (&signcolumn =~ '')
        let &signcolumn = 'yes'
        let b:gutterwidth = 2
    endif
endfunction

augroup vimrc
    " clear existing definitions in this group
    autocmd!

    " enable sign column (when appropriate), set textwidth, set wrapping indent
    autocmd BufWinEnter,BufRead,BufWrite,VimResized *
    \   call SetSignColumn(@%, &modifiable)
    \|  let b:numberwidth = &number * (1 + float2nr(ceil(log10(line("$") + 1))))
    \|  let &textwidth = 79 - b:gutterwidth - b:numberwidth
    \|  let &breakindentopt = "shift:" . (&ts-1)

    " autosave named files
    autocmd CursorHold ?* nested if empty(&buftype) | update | endif

    " convert always to utf-8
    autocmd BufWinEnter,BufRead,BufWritePost ?* silent! set fileencoding=utf-8

    " don't spell check help files
    autocmd FileType help set nospell

    " syntax highlight a minimum of 2000 lines (faster scrolling)
    autocmd Syntax * syn sync minlines=2000 maxlines=2000

    " enable syntax, load default syntax, and show guides for non-text files
    let textFiletypes =
    \   ['markdown', 'qf', 'help', 'tex', 'latex', 'text', '']
    autocmd BufWinEnter,BufRead * nested
    \   if !exists("g:syntax_on")
    \|      syntax on
    \|      syntax enable
    \|  endif
    \|  if index(textFiletypes, &filetype) < 0
    \|      source $HOME/.vim/after/syntax/default.vim
    \|      source $HOME/.vim/after/syntax/indent_guides.vim
    \|      let b:easytags_auto_update = 1
    \|      let b:easytags_auto_highlight = 1
    \|  endif
    \|  set concealcursor=cn
    \|  set conceallevel=1

    " treat certain extensions as xml
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.sdf,*.world,*.model,*.xacro*.config,*.launch,*.plist
    \   set ft=xml

    " treat certain ros configuration files as conf files
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.msg,*.srv,*.action
    \   set ft=conf
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.vcg
    \   set ft=dosini
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.yml,*.rviz
    \   set ft=yaml

    "" treat .sh files as .bash
    "autocmd BufWinEnter,BufRead,BufWritePost
    "\   *.sh
    "\   set ft=bash

    " treat .m files as matlab
    autocmd BufWinEnter,BufRead,BufWritePost
    \   *.m
    \   set ft=matlab

    " cmake custom autocompletion
    autocmd BufWinEnter,BufRead,BufWritePost
    \   CMakeLists.txt,*.cmake
    \   set complete=.,k
    \|  set dictionary=$HOME/.vim/words/cmake.txt

    " close loclists with buffer
    autocmd QuitPre * if empty(&buftype) | lclose | endif

    " remember state
    "au BufWinLeave,BufWrite * silent! mkview
    "au BufWinEnter,BufRead * silent! loadview
augroup END
