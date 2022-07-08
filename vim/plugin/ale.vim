" ALE
let g:ale_echo_msg_format = '[%linter%] %severity%%(code)%: %s'
let g:ale_sign_column_always = 1
"let g:ale_sign_error = '✘'
"let g:ale_sign_warning = '!'
let g:ale_sign_error = '┃'
let g:ale_sign_warning = '┃'
let g:ale_fix_on_save = 1
let &omnifunc = 'ale#completion#OmniFunc'
let g:ale_completion_enabled = 1
let g:ale_completion_delay = &updatetime

let g:ale_linters = {
\   'cpp': ['ccls', 'clang', 'clangtidy', 'cppcheck'],
\   'python': ['pylsp', 'flake8']}
let g:ale_fixers = {
\   'cpp': [{-> execute("undojoin", "silent!") + 0}, 'clang-format'],
\   'python': [{-> execute("undojoin", "silent!") + 0}, 'isort', 'autopep8'],
\   '*': [{-> execute("undojoin", "silent!") + 0}, 'remove_trailing_lines', 'trim_whitespace']}

let g:ale_cpp_ccls_init_options = {'cache': {'directory': '/tmp/ccls/cache'}}
let g:ale_cpp_clang_executable = 'clang++'
let g:ale_cpp_clang_options = '-Wall -Wextra'
let g:ale_cpp_clangtidy_checks = [
\   '*',
\   '-llvmlibc-*',
\   '-fuchsia-*']
let g:ale_cpp_cppcheck_options = '--enable=all'
