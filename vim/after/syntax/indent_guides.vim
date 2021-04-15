function! IndentGuides()
    let position = range(&shiftwidth + 1, &textwidth > 0 ? &textwidth : 80, &shiftwidth)
    call map(position, '"\\%" . v:val . "v"')
    let pattern = '\%(\_^.*  \+\)\@<=\%(' . join(position, '\|') . '\) '
    execute 'syntax match Normal "' . pattern . '" conceal cchar=│'
endfunction

call IndentGuides()
