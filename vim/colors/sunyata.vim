" Vim color file
" Maintainer:   George Sotirchos <gsotirch@gmail.com>

" handy help sections:
" group-name, highlight-groups, cterm-colors

set notermguicolors
set t_Co=16
"hi! clear
"if exists("syntax_on")
"    syntax reset
"endif
let g:colors_name="sunyata"


hi! Normal         cterm=none      ctermfg=none ctermbg=none
hi! Comment        cterm=none      ctermfg=2    ctermbg=none term=none

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

" statements
hi! Statement      cterm=bold      ctermfg=5    ctermbg=none
hi! link Conditional Statement
hi! link Repeat      Statement
hi! link Label       Statement
hi! link Keyword     Statement
hi! link Exception   Statement
hi! link Operator    Statement

" variable names
hi! Function       cterm=none      ctermfg=6    ctermbg=none
hi! Identifier     cterm=none      ctermfg=14   ctermbg=none

" constants
hi! String         cterm=none      ctermfg=9    ctermbg=none
hi! Character      cterm=none      ctermfg=11   ctermbg=none
hi! link Constant Character"
hi! link Number   Character
hi! link Float    Number
hi! link Boolean  Character

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
hi! Dimmed           cterm=none      ctermfg=7    ctermbg=none
hi! MyStrikethrough cterm=strikethrough ctermfg=7 ctermbg=none
hi! link MyParens   Dimmed
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
hi! SpellLocal     cterm=none      ctermfg=3    ctermbg=none
hi! link SpellRare SpellLocal
hi! link DimmedMsg   Dimmed

" visual elements
hi! clear CursorLine
hi! clear Search
hi! clear IncSearch
hi! clear Visual
hi! clear SignColumn
hi! Search         cterm=none      ctermfg=15   ctermbg=3
hi! IncSearch      cterm=none      ctermfg=15   ctermbg=11
hi! Visual                                      ctermbg=0
hi! ColorColumn    cterm=none      ctermfg=3    ctermbg=none
hi! CursorLineNr   cterm=none      ctermfg=7    ctermbg=none
hi! NonText        cterm=none      ctermfg=8    ctermbg=none
hi! link LineNr      NonText
hi! link VertSplit   NonText
hi! link Folded      NonText
hi! link FoldColumn  NonText
hi! link Conceal     OtherType

" menus and messages
hi! Underlined     cterm=underline ctermfg=4    ctermbg=none
hi! Directory      cterm=none      ctermfg=12   ctermbg=none
hi! ModeMsg        cterm=bold      ctermfg=4    ctermbg=none
hi! Question       cterm=none      ctermfg=3    ctermbg=none
hi! MsgArea        cterm=none      ctermfg=none ctermbg=none
hi! ToolbarLine    cterm=none      ctermfg=none ctermbg=8
hi! Pmenu          cterm=none      ctermfg=none ctermbg=0
hi! PmenuSel       cterm=none      ctermfg=none ctermbg=4
hi! PmenuThumb     cterm=reverse   ctermfg=none ctermbg=none
hi! link PmenuSbar   Pmenu
hi! link Title       SpecialComment
hi! link TabLineSel  SpecialComment
hi! link TabLine     ToolbarButton
hi! link TabLineFill ToolbarButton
hi! link MoreMsg     ModeMsg
hi! link Ignore      NonText
hi! link EndOfBuffer NonText
hi! link SpecialKey  NonText

" Statusline
hi! clear StatusLine
hi! clear StatusLineNC
hi! StatusLine     cterm=none                   ctermbg=0
hi! StatusLineNC   cterm=none      ctermfg=7    ctermbg=0
hi! SLGitDimmed      cterm=reverse   ctermfg=7    ctermbg=none
hi! SLFileDimmed     cterm=none                   ctermbg=8
hi! SLFilePath     cterm=none      ctermfg=7    ctermbg=0
hi! SLFileName     cterm=bold                   ctermbg=0
hi! link SLGitDimmedNC      StatusLineNC
hi! link SLFileDimmedNC     StatusLineNC
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
hi! DiffAdded                      ctermfg=2    ctermbg=none
hi! DiffChanged                    ctermfg=none ctermbg=none
hi! DiffRemoved                    ctermfg=1    ctermbg=none
hi! link diffNewFile SpecialComment
hi! link diffFile    SpecialComment
hi! link diffLine    SpecialComment
hi! link diffSubname SpecialComment

" ALE
hi! link ALEVirtualTextError        ErrorMsg
hi! link ALEVirtualTextWarning      WarningMsg
hi! link ALEVirtualTextDimmed         MyParens
hi! link ALEVirtualTextStyleError   ALEVirtualTextDimmed
hi! link ALEVirtualTextStyleWarning ALEVirtualTextDimmed
"hi! link ALEErrorLine    Normal
"hi! link ALEWarningLine  Normal

" CoC
hi! CocHighlightText                                    ctermbg=0
hi! CocVirtualText         cterm=none      ctermfg=8    ctermbg=0
hi! CocErrorFloat          cterm=none      ctermfg=1    ctermbg=0
hi! CocWarningFloat        cterm=none      ctermfg=3    ctermbg=0
hi! CocDimmedFloat           cterm=none      ctermfg=none ctermbg=0
hi! CocHintFloat           cterm=none      ctermfg=12   ctermbg=0
hi! link CocErrorSign          ErrorMsg
hi! link CocErrorVirtualText   CocErrorFloat
hi! link CocWarningSign        WarningMsg
hi! link CocWarningVirtualText CocWarningFloat
hi! link CocDimmedSign           DimmedMsg
hi! link CocDimmedVirtualText    CocDimmedFloat
hi! link CocHintSign           HintMsg
hi! link CocHintVirtualText    CocHintFloat
hi! link CocHighlightRead      CocHighlightText

" Copilot
"hi! link CopilotSuggestion    NonText
"hi! link CopilotAnnotation    Comment
hi! link CopilotWelcome       ModeMsg
hi! link CopilotPrompt        NonText
hi! link CopilotSeparatorLine NonText
hi! link CopilotSeparatorIcon Normal
"hi! link CopilotWaiting       Comment
