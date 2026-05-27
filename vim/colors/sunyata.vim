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

if s:is_dark
    let s:bg = '0'
    let s:bg_dim = '8'
    let s:fg_dim = '7'
    let s:fg = '15'
else
    let s:bg = '15'
    let s:bg_dim = '7'
    let s:fg_dim = '8'
    let s:fg = '0'
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
execute 'hi! DocComment      cterm=italic            ctermfg=' . s:bg_dim . '       ctermbg=none'
hi! Done            cterm=bold              ctermfg=2       ctermbg=none
hi! Debug           cterm=bold              ctermfg=11      ctermbg=none
execute 'hi! MembOperator    cterm=bold              ctermfg=' . s:fg_dim . '       ctermbg=none'
execute 'hi! Dimmed          cterm=none              ctermfg=' . s:fg_dim . '       ctermbg=none'
execute 'hi! MyStrikethrough cterm=strikethrough     ctermfg=' . s:bg_dim . '       ctermbg=none'
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
execute 'hi! Search          cterm=none              ctermfg=none    ctermbg=' . s:bg
execute 'hi! IncSearch       cterm=bold              ctermfg=none    ctermbg=' . s:bg
execute 'hi! Visual          cterm=none              ctermfg=none    ctermbg=' . s:bg_dim
hi! ColorColumn     cterm=none              ctermfg=3       ctermbg=none
execute 'hi! CursorLineNr    cterm=none              ctermfg=' . s:bg_dim . '       ctermbg=none'
execute 'hi! NonText         cterm=none              ctermfg=' . s:fg_dim . '       ctermbg=none'
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
execute 'hi! ToolbarLine     cterm=none              ctermfg=none    ctermbg=' . s:fg_dim
execute 'hi! Pmenu           cterm=none              ctermfg=' . s:bg . '      ctermbg=' . s:fg_dim
execute 'hi! PmenuSel        cterm=none              ctermfg=' . s:bg . '      ctermbg=4'
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
execute 'hi! StatusLine      cterm=none              ctermfg=none    ctermbg=' . s:bg_dim
execute 'hi! StatusLineNC    cterm=none              ctermfg=' . s:fg_dim . '      ctermbg=' . s:bg
execute 'hi! SLFileName      cterm=bold              ctermfg=none    ctermbg=' . s:bg_dim
execute 'hi! SLFileNameNC    cterm=bold              ctermfg=' . s:fg_dim . '      ctermbg=' . s:bg
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
execute 'hi! CocVirtualText  cterm=none              ctermfg=' . s:fg_dim . '       ctermbg=none'
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
