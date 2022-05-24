let g:easytags_auto_update = 0  " overriden per buffer by filetype-specific autocommand
let g:easytags_auto_highlight = 0  " overriden per buffer by filetype-specific autocommand
let g:easytags_async = 1
let g:easytags_always_enabled = 1
let g:easytags_on_cursorhold = 1
let g:easytags_updatetime_min = 1000
let g:easytags_syntax_keyword = "auto"
let g:easytags_include_members = 1
let g:easytags_resolve_links = 1
let g:easytags_cmd = 'ctags'
let g:easytags_opts = [
\   "--excmd=combine",
\   "--fields=+l",
\   "--kinds-Python=+l",
\   "--kinds-C=+lpxN",
\   "--kinds-C++=+lpxN",
\   "--extras=+q"
\]
let g:easytags_file = "~/.vim/tags"
let b:easytags_file =
\   $HOME . "/.vim/tags/"
\       . substitute(expand('%:p'), "/", "_", "g")
\       . ".ctags"
let &tags = b:easytags_file
let g:easytags_dynamic_files = 1
