" Override ALE's shellcheck handler to be robust against stdout pollution
" (e.g., when ~/.bash_profile prints to stdout during login shell startup)

function! s:RobustShellcheckHandle(buffer, version, lines) abort
    " Find the first line that looks like valid JSON to avoid parsing garbage
    let l:json_lines = []
    for l:line in a:lines
        " shellcheck json1 outputs a dictionary, old json format outputs a list
        if l:line =~# '^{.*}$' || l:line =~# '^\[.*\]$'
            call add(l:json_lines, l:line)
            break
        endif
    endfor

    " If we couldn't find JSON, fall back to empty to avoid json_decode errors
    " or E1206 when passing numbers/strings to has_key()
    if empty(l:json_lines)
        return []
    endif

    " Call the original ALE handler but ONLY with the valid JSON line
    return ale#handlers#shellcheck#Handle(a:buffer, a:version, l:json_lines)
endfunction

" Redefine the shellcheck linter, keeping everything the same but swapping the callback
call ale#linter#Define('sh', {
\   'name': 'shellcheck',
\   'executable': {buffer -> ale#Var(buffer, 'sh_shellcheck_executable')},
\   'cwd': function('ale#handlers#shellcheck#GetCwd'),
\   'command': {buffer -> ale#semver#RunWithVersionCheck(
\       buffer,
\       ale#Var(buffer, 'sh_shellcheck_executable'),
\       '%e --version',
\       function('ale#handlers#shellcheck#GetCommand'),
\   )},
\   'callback': {buffer, lines -> ale#semver#RunWithVersionCheck(
\       buffer,
\       ale#Var(buffer, 'sh_shellcheck_executable'),
\       '%e --version',
\       {buffer, version -> s:RobustShellcheckHandle(buffer, version, lines)}
\   )},
\})
