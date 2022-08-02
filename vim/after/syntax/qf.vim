syntax match qfWarning "\(|.*\s\=\)\@<=warning\(\s\=.*|\)\@=" containedin=ALL contained
syntax match qfInfo "\(|.*\s\=\)\@<=info\(\s\=.*|\)\@=" containedin=ALL contained

exe "hi! link qfSeparator Normal"
exe "hi! link qfLineNr    SpecialComment"
exe "hi! link qfFileName  Constant"
exe "hi! link qfError     Error"
exe "hi! link qfWarning   Todo"
exe "hi! link qfInfo      CursorLineNr"
