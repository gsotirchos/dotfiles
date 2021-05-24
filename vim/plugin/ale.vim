" ALE
let g:ale_list_window_size = 6
let g:ale_echo_msg_format = '%linter%::%severity%% code% -- %s'
let g:ale_sign_column_always = 1
let g:ale_sign_error = '✘'
let g:ale_sign_warning = '!'
let g:ale_linters = {'cpp': ['ccls']}
let &omnifunc = 'ale#completion#OmniFunc'
let g:ale_completion_enabled = 1
let g:ale_completion_delay = 400
let g:ale_cpp_ccls_init_options = {
\   'cache': {
\       'directory': '/tmp/ccls/cache'
\   }
\}
