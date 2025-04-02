let g:easytags_suppress_ctags_warning = 1
let g:easytags_auto_update = 0  " overriden per buffer by filetype-specific autocommand
let g:easytags_async = 1
let g:easytags_always_enabled = 1
let g:easytags_on_cursorhold = 1
let g:easytags_updatetime_min = 1000
let g:easytags_syntax_keyword = 'auto'  " set this to 'always' if 'auto' if there is slowdown
let g:easytags_include_members = 1
let g:easytags_resolve_links = 1
let g:easytags_cmd = 'ctags'
let g:easytags_opts = [
\   '--excmd=mix',
\   '--fields=+lnZs',
\   '--kinds-Python=+l',
\   '--kinds-C=+lpxAN',
\   '--kinds-C++=+lpxAN',
\   '--extras=+qr'
\]
let g:easytags_file = '~/.vim/tags'
let b:easytags_file =
\   $HOME . '/.vim/tags/'
\       . substitute(expand('%:p'), '/', '%', 'g')
\       . '.ctags'
let &tags = b:easytags_file
let g:easytags_dynamic_files = 1
