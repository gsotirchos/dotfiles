" Vim color file
" Maintainer:   George Sotirchos <gsotirch@gmail.com>

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

"set background=dark " or light
set notermguicolors
set t_Co=16
hi! clear
if exists("syntax_on")
    syntax reset
endif
let g:colors_name="sunyata"

" Colors
let color_0='#000000'
let color_1='#E90B18'
let color_2='#799F79'
let color_3='#989774'
let color_4='#779D9D'
let color_5='#D3D3D3'
let color_6='#D3D3D3'
let color_7='#959595'
let color_8='#303030'
let color_9=color_1
let color_10=color_2
let color_11=color_3
let color_12=color_4
let color_13=color_5
let color_14=color_6
let color_15='#FFFFFF'

let color_fg='#959595'
let color_bg='#000000'

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


hi! Normal         cterm=NONE      ctermfg=NONE ctermbg=NONE

" comments
hi! Comment        cterm=NONE      ctermfg=7    ctermbg=NONE term=NONE

" constants
hi! String         cterm=NONE      ctermfg=9    ctermbg=NONE
hi! Character      cterm=NONE      ctermfg=11   ctermbg=NONE
hi! link Constant Character"
"hi! link Number   Character
"hi! link Float    Number
"hi! link Boolean  Character

" variable names
hi! Function       cterm=NONE      ctermfg=6    ctermbg=NONE
hi! Identifier     cterm=NONE      ctermfg=14   ctermbg=NONE

" statements
hi! Statement      cterm=bold      ctermfg=5    ctermbg=NONE
hi! link Conditional Statement
hi! link Repeat      Statement
hi! link Label       Statement
hi! link Keyword     Statement
hi! link Exception   Statement
hi! link Operator    Statement

" generic Preprocessor
hi! PreProc        cterm=NONE      ctermfg=3    ctermbg=NONE
hi! link Include   PreProc
hi! link Define    PreProc
hi! link Macro     PreProc
hi! link PreCondit PreProc

" types
hi! Type           cterm=bold      ctermfg=13   ctermbg=NONE
hi! link Structure    Statement
hi! link StorageClass Statement
hi! link Typedef      Statement

" special symbols
hi! Delimiter      cterm=NONE      ctermfg=2    ctermbg=NONE
hi! link Tag         Delimiter
hi! link Special     Character
hi! link SpecialChar Character

" my custom groups
hi! MembOperator   cterm=bold      ctermfg=7    ctermbg=NONE
hi! OtherType      cterm=NONE      ctermfg=12   ctermbg=NONE
hi! SpecialComment cterm=bold      ctermfg=15   ctermbg=NONE
hi! DocComment     cterm=italic    ctermfg=8    ctermbg=NONE
hi! Done           cterm=bold      ctermfg=2    ctermbg=NONE
hi! Debug          cterm=bold      ctermfg=3    ctermbg=NONE

" errors and warnings
hi! MatchParen     cterm=bold      ctermfg=11   ctermbg=8
hi! Error          cterm=bold      ctermfg=1    ctermbg=NONE
hi! ErrorMsg       cterm=NONE      ctermfg=1    ctermbg=NONE
hi! WarningMsg     cterm=NONE      ctermfg=3    ctermbg=NONE
hi! Todo           cterm=bold      ctermfg=9    ctermbg=11
hi! SpellBad       cterm=underline ctermfg=1    ctermbg=NONE
hi! SpellCap       cterm=underline ctermfg=3    ctermbg=NONE
hi! Underlined     cterm=underline ctermfg=4    ctermbg=NONE
hi! Directory      cterm=NONE      ctermfg=12   ctermbg=NONE
hi! SpellLocal     cterm=NONE      ctermfg=3    ctermbg=NONE
hi! link SpellRare SpellLocal

" visual elements
hi! Search         cterm=reverse   ctermfg=3    ctermbg=NONE
hi! IncSearch      cterm=reverse   ctermfg=11   ctermbg=NONE
hi! clear Visual
hi! Visual                                      ctermbg=0
hi! SignColumn     cterm=NONE      ctermfg=NONE ctermbg=NONE
hi! EndOfBuffer    cterm=NONE      ctermfg=0    ctermbg=NONE
hi! ColorColumn    cterm=NONE      ctermfg=3    ctermbg=NONE
hi! StatusLine     cterm=NONE      ctermfg=NONE ctermbg=8
hi! StatusLineNC   cterm=NONE      ctermfg=7    ctermbg=0
hi! Folded         cterm=bold      ctermfg=8    ctermbg=NONE
hi! Conceal        cterm=NONE      ctermfg=8    ctermbg=NONE
hi! link LineNr           Conceal
hi! link CursorLineNr     Comment
hi! link VertSplit        Comment
hi! link StatusLineTerm   StatusLine
hi! link StatusLineTermNC StatusLineNC
hi! link FoldColumn       EndOfBuffer
hi! clear CursorLine

" menus and messages
hi! Question       cterm=NONE      ctermfg=3    ctermbg=NONE
hi! ToolbarLine    cterm=NONE      ctermfg=NONE ctermbg=8
hi! ToolbarButton  cterm=bold      ctermfg=0    ctermbg=7
hi! WildMenu       cterm=NONE      ctermfg=0    ctermbg=3
hi! Pmenu          cterm=NONE      ctermfg=15   ctermbg=0
hi! PmenuSel       cterm=NONE      ctermfg=15   ctermbg=4
hi! PmenuThumb     cterm=reverse   ctermfg=15   ctermbg=NONE
hi! link PmenuSbar   Pmenu
hi! link Title       SpecialComment
hi! link TabLineSel  SpecialComment
hi! link TabLine     ToolbarButton
hi! link TabLineFill ToolbarButton
hi! link ModeMsg     Type
hi! link MoreMsg     ModeMsg
hi! link NonText     Conceal
hi! link Ignore      Conceal
hi! link SpecialKey  Conceal

" ALE
hi! ALEVirtualTextError   cterm=NONE ctermfg=1  ctermbg=NONE
hi! ALEVirtualTextWarning cterm=NONE ctermfg=3  ctermbg=NONE
hi! ALEVirtualTextInfo    cterm=NONE ctermfg=8  ctermbg=NONE
hi! link ALEVirtualTextStyleError   ALEVirtualTextInfo
hi! link ALEVirtualTextStyleWarning ALEVirtualTextInfo

" vimdiff
hi! clear DiffAdd
hi! clear DiffChange
hi! clear DiffDelete
hi! clear DiffText
hi! DiffAdd ctermfg=10 ctermbg=0
hi! DiffChange ctermbg=0
hi! DiffDelete ctermfg=9 ctermbg=0
hi! DiffText ctermfg=11 ctermbg=0
