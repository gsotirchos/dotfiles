" Vim color file
" Maintainer:   George Sotirchos <gsotirch@gmail.com>

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

"set background=dark " or light
set notermguicolors
set t_Co=16
"if exists("syntax_on")
"    syntax reset
"endif
"hi! clear
let g:colors_name="sunyata"

"hi Normal
"
" OR
"
" highlight clear Normal
" set background&
" highlight clear
" if &background == "light"
"   highlight Error ...
"   ...
" else
"   highlight Error ...
"   ...
" endif
"
" A good way to see what your colorscheme does is to follow this procedure:
" :w
" :so %
"
" Then to see what the current setting is use the highlight command.
" For example,
" :hi Cursor
" gives
" Cursor         xxx guifg=bg guibg=fg


hi! Normal         cterm=none      ctermfg=none ctermbg=none

" comments
"hi! Comment        cterm=none      ctermfg=7    ctermbg=none term=none
hi! Comment        cterm=none      ctermfg=2    ctermbg=none term=none

" constants
hi! String         cterm=none      ctermfg=9    ctermbg=none
hi! Character      cterm=none      ctermfg=11   ctermbg=none
hi! link Constant Character"
"hi! link Number   Character
"hi! link Float    Number
"hi! link Boolean  Character

" variable names
hi! Function       cterm=none      ctermfg=6    ctermbg=none
hi! Identifier     cterm=none      ctermfg=14   ctermbg=none

" statements
hi! Statement      cterm=bold      ctermfg=5    ctermbg=none
hi! link Conditional Statement
hi! link Repeat      Statement
hi! link Label       Statement
hi! link Keyword     Statement
hi! link Exception   Statement
hi! link Operator    Statement

" generic Preprocessor
hi! PreProc        cterm=none      ctermfg=3    ctermbg=none
hi! link Include   PreProc
hi! link Define    PreProc
hi! link Macro     PreProc
hi! link PreCondit PreProc

" types
hi! Type           cterm=bold      ctermfg=13   ctermbg=none
hi! link Structure    Statement
hi! link StorageClass Statement
hi! link Typedef      Statement

" special symbols
hi! Delimiter      cterm=none      ctermfg=2    ctermbg=none
hi! link Tag         Delimiter
hi! link Special     Character
hi! link SpecialChar Character

" my custom groups
hi! OtherType      cterm=none      ctermfg=12   ctermbg=none
hi! SpecialComment cterm=bold      ctermfg=none ctermbg=none
hi! DocComment     cterm=italic    ctermfg=8    ctermbg=none
hi! Done           cterm=bold      ctermfg=2    ctermbg=none
hi! Debug          cterm=bold      ctermfg=11   ctermbg=none
hi! MembOperator   cterm=bold      ctermfg=7    ctermbg=none
hi! Info           cterm=none      ctermfg=7    ctermbg=none
hi! link MyParens   Info
hi! link MyNote     Normal
hi! link MyTagMark  SpecialComment
hi! link MyUrl      Underlined
hi! link MyEquals   Statement
hi! link MyOperator OtherType

" errors and warnings
hi! MatchParen     cterm=bold      ctermfg=11   ctermbg=0
hi! Error          cterm=bold      ctermfg=1    ctermbg=none
hi! ErrorMsg       cterm=none      ctermfg=1    ctermbg=none
hi! Warning        cterm=bold      ctermfg=3    ctermbg=none
hi! WarningMsg     cterm=none      ctermfg=3    ctermbg=none
hi! HintMsg        cterm=none      ctermfg=12   ctermbg=none
hi! Todo           cterm=bold      ctermfg=15   ctermbg=11
hi! SpellBad       cterm=underline ctermfg=1    ctermbg=none
hi! SpellCap       cterm=underline ctermfg=3    ctermbg=none
hi! Underlined     cterm=underline ctermfg=4    ctermbg=none
hi! Directory      cterm=none      ctermfg=12   ctermbg=none
hi! SpellLocal     cterm=none      ctermfg=3    ctermbg=none
hi! link SpellRare SpellLocal
hi! link InfoMsg   Info

" TODO
" visual elements
hi! clear Search
hi! Search         cterm=none      ctermfg=15   ctermbg=3
hi! clear IncSearch
hi! IncSearch      cterm=none      ctermfg=15   ctermbg=11
hi! clear Visual
hi! Visual                                      ctermbg=0
hi! SignColumn     cterm=none      ctermfg=none ctermbg=none
hi! EndOfBuffer    cterm=none      ctermfg=0    ctermbg=none
hi! ColorColumn    cterm=none      ctermfg=3    ctermbg=none
hi! Folded         cterm=none      ctermfg=8    ctermbg=none
hi! LineNr         cterm=none      ctermfg=8
hi! CursorLineNr   cterm=none      ctermfg=7
hi! link Conceal    LineNr
hi! link VertSplit  LineNr
hi! link FoldColumn EndOfBuffer
hi! clear CursorLine

" menus and messages
hi! ModeMsg        cterm=bold      ctermfg=4    ctermbg=none
hi! MsgArea        cterm=none      ctermfg=none ctermbg=none
hi! Question       cterm=none      ctermfg=3    ctermbg=none
hi! ToolbarLine    cterm=none      ctermfg=none ctermbg=8
hi! ToolbarButton  cterm=bold      ctermfg=0    ctermbg=7
hi! WildMenu       cterm=none      ctermfg=0    ctermbg=3
hi! Pmenu          cterm=none      ctermfg=none ctermbg=0
hi! PmenuSel       cterm=none      ctermfg=none ctermbg=4
hi! PmenuThumb     cterm=reverse   ctermfg=none ctermbg=none
hi! link PmenuSbar   Pmenu
hi! link Title       SpecialComment
hi! link TabLineSel  SpecialComment
hi! link TabLine     ToolbarButton
hi! link TabLineFill ToolbarButton
hi! link MoreMsg     ModeMsg
hi! link NonText     Conceal
hi! link Ignore      Conceal
hi! link SpecialKey  Conceal

" Statusline
hi! clear StatusLine
hi! clear StatusLineNC
hi! StatusLine     cterm=none                   ctermbg=0
hi! StatusLineNC   cterm=none      ctermfg=7    ctermbg=0
hi! SLGitInfo      cterm=none      ctermfg=0    ctermbg=7
hi! SLFileInfo     cterm=none                   ctermbg=8
hi! SLFilePath     cterm=none      ctermfg=7    ctermbg=0
hi! SLFileName     cterm=bold                   ctermbg=0
hi! link SLGitInfoNC      StatusLineNC
hi! link SLFileInfoNC     StatusLineNC
hi! link SLFilePathNC     StatusLineNC
hi! link SLFileNameNC     StatusLineNC
hi! link StatusLineTerm   StatusLine
hi! link StatusLineTermNC StatusLineNC

" Vimdiff
hi! clear DiffAdd
hi! clear DiffChange
hi! clear DiffDelete
hi! clear DiffText
hi! DiffAdd                        ctermfg=10   ctermbg=0
hi! DiffChange                                  ctermbg=0
hi! DiffDelete                     ctermfg=9    ctermbg=0
hi! DiffText                       ctermfg=11   ctermbg=0

" ALE
hi! link ALEVirtualTextError        ErrorMsg
hi! link ALEVirtualTextWarning      WarningMsg
hi! link ALEVirtualTextInfo         MyParens
hi! link ALEVirtualTextStyleError   ALEVirtualTextInfo
hi! link ALEVirtualTextStyleWarning ALEVirtualTextInfo
"hi! link ALEErrorLine    Normal
"hi! link ALEWarningLine  Normal

" CoC
hi! CocHighlightText                                    ctermbg=0
hi! CocVirtualText         cterm=none      ctermfg=8    ctermbg=0
hi! CocErrorFloat          cterm=none      ctermfg=1    ctermbg=0
hi! CocWarningFloat        cterm=none      ctermfg=3    ctermbg=0
hi! CocInfoFloat           cterm=none      ctermfg=none ctermbg=0
hi! CocHintFloat           cterm=none      ctermfg=12   ctermbg=0
hi! link CocErrorSign          ErrorMsg
hi! link CocErrorVirtualText   CocErrorFloat
hi! link CocWarningSign        WarningMsg
hi! link CocWarningVirtualText CocWarningFloat
hi! link CocInfoSign           InfoMsg
hi! link CocInfoVirtualText    CocInfoFloat
hi! link CocHintSign           HintMsg
hi! link CocHintVirtualText    CocHintFloat
hi! link CocHighlightRead      CocHighlightText

" Copilot
"hi! link CopilotSuggestion    NonText
"hi! link CopilotAnnotation    Comment
hi! link CopilotWelcome       ModeMsg
hi! link CopilotSeparatorLine NonText
hi! link CopilotSeparatorIcon Normal
hi! link CopilotPrompt        NonText
"hi! link CopilotWaiting       Comment
