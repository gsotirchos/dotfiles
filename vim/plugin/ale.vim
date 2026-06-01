scriptencoding utf-8

" Configure ALE strictly for static checking (no LSP)
let g:ale_disable_lsp = 1
let g:ale_completion_enabled = 0

let g:ale_sign_info = '●'
let g:ale_sign_error = '▲'
let g:ale_sign_warning = '◼'
let g:ale_virtualtext_delay = &updatetime
let g:ale_virtualtext_single = 1
let g:ale_virtualtext_prefix = ' ◀︎ '
let g:ale_echo_msg_format = '[%linter%] %code: %%s'

" Explicitly enable static-checking linters (No LSPs)
let g:ale_linters_explicit = 1
let g:ale_linters = {
\   'vim': ['vint'],
\   'sh': ['shellcheck', 'bashate'],
\   'cmake': ['cmake_lint'],
\   'cpp': ['clangtidy', 'cppcheck', 'cc'],
\   'python': ['ruff'],
\   'tex': ['chktex', 'proselint'],
\   'markdown': ['markdownlint'],
\   'json': ['jq'],
\}

" Custom fixer for JSON (strips trailing commas and comments, then formats)
function! ALEFixJson(buffer) abort
    return { 'command': expand($MACOS_DOTFILES . '/bin/fix-json') }
endfunction

" Fixers on save (safe undojoin wrapper to prevent undo history breakage)
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   'sh': [{ -> execute('undojoin', 'silent!') + 0 }, 'shfmt'],
\   'cmake': [{ -> execute('undojoin', 'silent!') + 0 }, 'cmakeformat'],
\   'cpp': [{ -> execute('undojoin', 'silent!') + 0 }, 'clang-format'],
\   'python': [{ -> execute('undojoin', 'silent!') + 0 }, 'ruff', 'ruff_format'],
\   'tex': [{ -> execute('undojoin', 'silent!') + 0 }, 'latexindent'],
\   'json': [{ -> execute('undojoin', 'silent!') + 0 }, 'ALEFixJson'],
\}

" Custom Tool Flags matching your modern outside-vim setup
let g:ale_sh_shellcheck_options = '--shell=bash'
let g:ale_sh_shfmt_options = '-ln=bash -i ' . &tabstop . ' -ci -bn -sr'
let g:ale_python_ruff_options = '--config ' . expand($MACOS_DOTFILES . '/pyproject.toml')
let g:ale_tex_latexindent_options = '-m -rv'
let g:ale_markdown_markdownlint_options = '--config ' . expand($MACOS_DOTFILES . '/markdownlint.json')
let g:ale_sh_bashate_executable = expand($MACOS_DOTFILES . '/bin/bashate')
