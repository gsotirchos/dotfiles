syntax match qfWarning "\(|.*\s\=\)\@<=warning\(\s\=.*|\)\@=" containedin=ALL contained
syntax match qfInfo "\(|.*\s\=\)\@<=info\(\s\=.*|\)\@=" containedin=ALL contained
syntax match qfHint "\(|.*\s\=\)\@<=hint\(\s\=.*|\)\@=" containedin=ALL contained


hi! link qfSeparator  NonText
hi! link qfSeparator1 qfSeparator
hi! link qfSeparator2 qfSeparator
hi! link qfLineNr     SpecialComment
hi! link qfFileName   Directory
hi! link qfError      Error
hi! link qfWarning    Warning
hi! link qfInfo       Normal
hi! link qfHint       Normal
