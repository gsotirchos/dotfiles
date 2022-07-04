syntax match qfWarning "\(|.*\d\s\)\@<=warning" containedin=qfLineNr contained

exe "hi! link qfSeparator Normal"
exe "hi! link qfLineNr    SpecialComment"
exe "hi! link qfFileName  Constant"
exe "hi! link qfError     Error"
exe "hi! link qfWarning   Todo"
