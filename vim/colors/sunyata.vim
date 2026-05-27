" Vim color file
" Maintainer: George Sotirchos <gsotirch@gmail.com>

" handy help sections:
" group-name, highlight-groups, cterm-colors

set notermguicolors
set t_Co=16
"hi! clear
"if exists("syntax_on")
"    syntax reset
"endif
let g:colors_name = 'sunyata'


let s:is_dark = 0 " Default to light

if &background ==# 'light'
    let s:is_dark = 0
elseif &background ==# 'dark'
    let s:is_dark = 1
else
    if !has('gui_running')
        if has('macunix')
            " macOS detection
            let s:mode = system('defaults read -g AppleInterfaceStyle 2>/dev/null')
            let s:is_dark = (v:shell_error == 0)
        elseif has('unix')
            " Linux detection (GTK/GNOME/Ubuntu standard)
            let s:mode = system('gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null')

            " If gsettings fails or isn't populated, try the generic XDG portal
            if v:shell_error || empty(s:mode)
                let s:mode = system('dbus-send --print-reply --dest=org.freedesktop.portal.Desktop /org/freedesktop/portal/desktop org.freedesktop.portal.Settings.Read string:"org.freedesktop.appearance" string:"color-scheme" 2>/dev/null')
            endif

            " 1 = prefer-dark, 2 = prefer-light. Also checks for the literal string 'dark'
            if s:mode =~? 'dark' || s:mode =~? '1'
                let s:is_dark = 1
            else
                let s:is_dark = 0
            endif
        endif
    endif
endif

if s:is_dark
    let &background = 'dark'
else
    let &background = 'light'
endif


" Entries are aligned in columns at intervals of 4:
"   HilightName |   cterm=...   |   |   |   ctermfg=... |   ctermbg=... |   |
"   link ThisHilightName    ThatHilightName |   |   |   |   |   |   |   |   |

hi! Normal          cterm=none              ctermfg=none    ctermbg=none
hi! Comment         cterm=none  term=none   ctermfg=2       ctermbg=none

" generic Preprocessor
hi! PreProc         cterm=none              ctermfg=3       ctermbg=none
hi! link Include    PreProc
hi! link Define     PreProc
hi! link Macro      PreProc
hi! link PreCondit  PreProc

" types
hi! Type            cterm=bold              ctermfg=13      ctermbg=none
hi! link Structure      Statement
hi! link StorageClass   Statement
hi! link Typedef        Statement

" statements
hi! Statement       cterm=bold              ctermfg=5       ctermbg=none
hi! link Conditional    Statement
hi! link Repeat         Statement
hi! link Label          Statement
hi! link Keyword        Statement
hi! link Exception      Statement
hi! link Operator       Statement

" variable names
hi! Function        cterm=none              ctermfg=4       ctermbg=none
hi! Identifier      cterm=none              ctermfg=12      ctermbg=none

" constants
hi! String          cterm=none              ctermfg=9       ctermbg=none
hi! Character       cterm=none              ctermfg=11      ctermbg=none
hi! link Constant   Character"
hi! link Number     Character
hi! link Float      Number
hi! link Boolean    Character

" special symbols
hi! Delimiter       cterm=none              ctermfg=2       ctermbg=none
hi! link Tag            Delimiter
hi! link Special        Character
hi! link SpecialChar    Character

" my custom groups
hi! OtherType       cterm=none              ctermfg=12      ctermbg=none
hi! SpecialComment  cterm=bold              ctermfg=none    ctermbg=none
if s:is_dark
    hi! DocComment      cterm=italic            ctermfg=8       ctermbg=none
    hi! MembOperator    cterm=bold              ctermfg=7       ctermbg=none
    hi! Dimmed          cterm=none              ctermfg=7       ctermbg=none
    hi! MyStrikethrough cterm=strikethrough     ctermfg=8       ctermbg=none
else
    hi! DocComment      cterm=italic            ctermfg=7       ctermbg=none
    hi! MembOperator    cterm=bold              ctermfg=8       ctermbg=none
    hi! Dimmed          cterm=none              ctermfg=8       ctermbg=none
    hi! MyStrikethrough cterm=strikethrough     ctermfg=7       ctermbg=none
endif
hi! Done            cterm=bold              ctermfg=2       ctermbg=none
hi! Debug           cterm=bold              ctermfg=11      ctermbg=none
hi! link MyParens   Dimmed
hi! link MyNote     Normal
hi! link MyTagMark  SpecialComment
hi! link MyUrl      Underlined
hi! link MyEquals   Statement
hi! link MyOperator OtherType

" errors and warnings
hi! MatchParen      cterm=underline         ctermfg=none    ctermbg=none
hi! Error           cterm=bold              ctermfg=1       ctermbg=none
hi! ErrorMsg        cterm=none              ctermfg=1       ctermbg=none
hi! Warning         cterm=bold              ctermfg=3       ctermbg=none
hi! WarningMsg      cterm=none              ctermfg=3       ctermbg=none
hi! HintMsg         cterm=none              ctermfg=12      ctermbg=none
hi! Todo            cterm=bold              ctermfg=11      ctermbg=none
hi! SpellBad        cterm=underline         ctermfg=1       ctermbg=none
hi! SpellCap        cterm=underline         ctermfg=3       ctermbg=none
hi! SpellLocal      cterm=none              ctermfg=3       ctermbg=none
hi! link SpellRare  SpellLocal
hi! link InfoMsg    Dimmed

" visual elements
hi! clear CursorLine
hi! clear Search
hi! clear IncSearch
hi! clear Visual
hi! clear SignColumn
hi! ColorColumn     cterm=none              ctermfg=3       ctermbg=none
if s:is_dark
    hi! Search          cterm=none              ctermfg=none    ctermbg=0
    hi! IncSearch       cterm=bold              ctermfg=none    ctermbg=0
    hi! Visual          cterm=none              ctermfg=none    ctermbg=8
    hi! CursorLineNr    cterm=none              ctermfg=8       ctermbg=none
    hi! NonText         cterm=none              ctermfg=7       ctermbg=none
else
    hi! Search          cterm=none              ctermfg=none    ctermbg=15
    hi! IncSearch       cterm=bold              ctermfg=none    ctermbg=15
    hi! Visual          cterm=none              ctermfg=none    ctermbg=7
    hi! CursorLineNr    cterm=none              ctermfg=7       ctermbg=none
    hi! NonText         cterm=none              ctermfg=8       ctermbg=none
endif
hi! link LineNr     NonText
hi! link VertSplit  NonText
hi! link Folded     NonText
hi! link FoldColumn NonText
hi! link Conceal    OtherType

" menus and messages
hi! Underlined      cterm=underline         ctermfg=4       ctermbg=none
hi! Directory       cterm=none              ctermfg=12      ctermbg=none
hi! ModeMsg         cterm=bold              ctermfg=1       ctermbg=none
hi! Question        cterm=none              ctermfg=3       ctermbg=none
hi! MsgArea         cterm=none              ctermfg=none    ctermbg=none
if s:is_dark
    hi! ToolbarLine     cterm=none              ctermfg=none    ctermbg=7
    hi! Pmenu           cterm=none              ctermfg=0       ctermbg=7
    hi! PmenuSel        cterm=none              ctermfg=0       ctermbg=4
else
    hi! ToolbarLine     cterm=none              ctermfg=none    ctermbg=8
    hi! Pmenu           cterm=none              ctermfg=15      ctermbg=8
    hi! PmenuSel        cterm=none              ctermfg=15      ctermbg=4
endif
hi! PmenuThumb      cterm=reverse           ctermfg=none    ctermbg=none
hi! link PmenuSbar      Pmenu
hi! link Title          SpecialComment
hi! link TabLineSel     SpecialComment
hi! link TabLine        ToolbarButton
hi! link TabLineFill    ToolbarButton
hi! link MoreMsg        ModeMsg
hi! link Ignore         NonText
hi! link EndOfBuffer    NonText
hi! link SpecialKey     NonText

" Statusline
hi! clear StatusLine
hi! clear StatusLineNC
if s:is_dark
    hi! StatusLine      cterm=none              ctermfg=none    ctermbg=8
    hi! StatusLineNC    cterm=none              ctermfg=7       ctermbg=0
    hi! SLFileName      cterm=bold              ctermfg=none    ctermbg=8
    hi! SLFileNameNC    cterm=bold              ctermfg=7       ctermbg=0
else
    hi! StatusLine      cterm=none              ctermfg=none    ctermbg=7
    hi! StatusLineNC    cterm=none              ctermfg=8       ctermbg=15
    hi! SLFileName      cterm=bold              ctermfg=none    ctermbg=7
    hi! SLFileNameNC    cterm=bold              ctermfg=8       ctermbg=15
endif
hi! link SLGitInfo          StatusLine
hi! link SLFileInfo         StatusLine
hi! link SLFilePath         StatusLine
hi! link StatusLineTerm     StatusLine
hi! link SLGitInfoNC        StatusLineNC
hi! link SLFileInfoNC       StatusLineNC
hi! link SLFilePathNC       StatusLineNC
hi! link StatusLineTermNC   StatusLineNC

"netrw
hi! netrwDir        cterm=bold              ctermfg=4       ctermbg=none
hi! netrwExe        cterm=bold              ctermfg=2       ctermbg=none
hi! netrwSymlink    cterm=bold              ctermfg=6       ctermbg=none
hi! link netrwClassify  Dimmed
hi! link netrwTreebar   NonText
hi! link netrwLink      MyOperator

" Vimdiff
hi! clear DiffAdd
hi! clear DiffChange
hi! clear DiffDelete
hi! clear DiffText
hi! DiffAdd                                 ctermfg=10      ctermbg=none
hi! DiffChange                              ctermfg=none    ctermbg=none
hi! DiffDelete                              ctermfg=9       ctermbg=none
hi! DiffText                                ctermfg=11      ctermbg=none
hi! DiffAdded                               ctermfg=2       ctermbg=none
hi! DiffChanged                             ctermfg=none    ctermbg=none
hi! DiffRemoved                             ctermfg=1       ctermbg=none
hi! link diffNewFile    SpecialComment
hi! link diffFile       SpecialComment
hi! link diffLine       SpecialComment
hi! link diffSubname    SpecialComment

" ALE
hi! link ALEVirtualTextError        ErrorMsg
hi! link ALEVirtualTextWarning      WarningMsg
hi! link ALEVirtualTextInfo         Dimmed
hi! link ALEVirtualTextStyleError   ALEVirtualTextInfo
hi! link ALEVirtualTextStyleWarning ALEVirtualTextInfo
"hi! link ALEErrorLine               Normal
"hi! link ALEWarningLine             Normal

" CoC
if s:is_dark
    hi! CocVirtualText  cterm=none              ctermfg=7       ctermbg=none
else
    hi! CocVirtualText  cterm=none              ctermfg=8       ctermbg=none
endif
hi! CocErrorFloat   cterm=none              ctermfg=1       ctermbg=none
hi! CocWarningFloat cterm=none              ctermfg=3       ctermbg=none
hi! CocInfoFloat    cterm=none              ctermfg=none    ctermbg=none
hi! CocHintFloat    cterm=none              ctermfg=12      ctermbg=none
hi! link CocErrorSign           ErrorMsg
hi! link CocErrorVirtualText    CocErrorFloat
hi! link CocWarningSign         WarningMsg
hi! link CocWarningVirtualText  CocWarningFloat
hi! link CocInfoSign            InfoMsg
hi! link CocInfoVirtualText     CocInfoFloat
hi! link CocHintSign            HintMsg
hi! link CocHintVirtualText     CocHintFloat
hi! link CocHighlightText       Search
hi! link CocHighlightRead       CocHighlightText

" Copilot
"hi! link CopilotSuggestion      NonText
"hi! link CopilotAnnotation      Comment
hi! link CopilotWelcome         ModeMsg
hi! link CopilotPrompt          NonText
hi! link CopilotSeparatorLine   NonText
hi! link CopilotSeparatorIcon   Normal
"hi! link CopilotWaiting         Comment
