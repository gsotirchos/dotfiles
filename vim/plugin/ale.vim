" ALE
let g:ale_echo_msg_format = '〈%linter%〉%s %(code)%'
let g:ale_sign_column_always = 1
let g:ale_sign_error = '▐'
let g:ale_sign_warning = '▐'
let g:ale_fix_on_save = 0  " TODO
let &omnifunc = 'ale#completion#OmniFunc'
let &completefunc = 'ale#completion#OmniFunc'
let g:ale_completion_enabled = 1
let g:ale_completion_delay = &updatetime
let g:ale_virtualtext_delay = &updatetime
let g:ale_virtualtext_single = 1
"let g:ale_virtualtext_prefix = '〈%linter%〉%type%: '
let g:ale_virtualtext_prefix = ' ◀︎ '

let g:ale_linters = {
\   'cpp': ['clangd', 'cc', 'clangtidy', 'cppcheck'],
\   'python': ['pylsp'],
\   'tex': ['texlab', 'chktex', 'proselint'],
\}
let g:ale_fixers = {
\   'sh': [
\       {-> execute('undojoin', 'silent!') + 0},
\       'shfmt'],
\   'cmake': [
\       {-> execute('undojoin', 'silent!') + 0},
\       'cmakeformat'],
\   'cpp': [
\       {-> execute('undojoin', 'silent!') + 0},
\       'clang-format'],
\   'python': [
\       {-> execute('undojoin', 'silent!') + 0},
\       'trim_whitespace',
\       'isort',
\       'autopep8',
\       'ruff'],
\   'tex': [
\       {-> execute('undojoin', 'silent!') + 0},
\       'latexindent'],
\}

let b:threads = (str2nr(system('nproc')) + 1) / 2

" CMake
let g:ale_cmake_cmake_lint_options = '-c ' . $HOME . '/.cmake-format --'

" Shell
let g:ale_sh_shellcheck_options = '--shell=bash'
let g:ale_sh_shfmt_options = '-ln=bash -i ' . &ts . ' -ci -bn -sr'
let g:ale_sh_bashate_options = "--ignore E003,E006,E042"

" C++
let g:ale_cpp_clangd_options = '
\   --background-index
\   --background-index-priority=background
\   --clang-tidy=false
\   --completion-style=detailed
\   --function-arg-placeholders
\   --header-insertion=iwyu
\   --header-insertion-decorators
\   --pch-storage=memory'
let g:ale_cpp_ccls_init_options = {
\   'cache': {'directory': $HOME . '/.cache/ccls'},
\   'index': {'threads' : b:threads}}
let g:ale_cpp_cc_executable = $CXX
let g:ale_cpp_cc_options = '-std=' . $CXX_STD . ' -Wall -Wextra -Wpedantic'
let g:ale_cpp_clangtidy_options = '-std=' . $CXX_STD
let g:ale_cpp_cppcheck_options = '--enable=all'

" Python
" use ruff and disable everything flake8
let g:ale_python_pylsp_config = {
\   'pylsp': {
\     'plugins': {
\       'ruff': {
\         'enabled': v:true,
\         'severities': {
\           'F401': 'I'},
\         'config': '~/.ruff.toml'},
\       'flake8': {
\         'enabled': v:false},
\       'pycodestyle': {
\         'enabled': v:false},
\       'pyflakes': {
\         'enabled': v:false},
\       'mccabe': {
\         'enabled': v:false},
\       'pyls_isort': {
\         'enabled': v:false}}}}
let g:ale_python_autopep8_options = '--global-config ~/.pycodestyle'

" Tex
let g:ale_tex_latexindent_options = '-m -rv'

" etc.
"let g:ale_matlab_mlint_executable = trim(system('which /Applications/MATLAB*.app/bin/maci64/mlint'))
