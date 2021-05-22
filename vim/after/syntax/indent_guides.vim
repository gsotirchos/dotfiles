function! IndentGuides()
    let position = range(&tabstop + 1, &textwidth > 0 ? &textwidth : 80, &tabstop)
    call map(position, '"\\%" . v:val . "v "')
    let pattern = '\%(\_^  \+\)\@<=\%(' . join(position, '\|') . '\)'
    execute 'syntax match Conceal "' . pattern . '" conceal cchar=│ containedIn=ALL transparent'
endfunction

call IndentGuides()
