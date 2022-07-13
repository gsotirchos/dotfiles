" Vim color file
" Maintainer:   Giorgos Sotirchos <630r63.7555@gmail.com>
" Last Change:
" URL:

" cool help screens
" :he group-name
" :he highlight-groups
" :he cterm-colors

" your pick:
set background=dark " or light
hi clear
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


exe "hi! Normal         cterm=NONE      ctermfg=NONE ctermbg=NONE gui=NONE      guifg=".color_fg" guibg=".color_bg

" comments
exe "hi! Comment        cterm=NONE      ctermfg=8    ctermbg=NONE gui=NONE      guifg=".color_8"  guibg=".color_bg

" constants
exe "hi! Constant       cterm=NONE      ctermfg=9    ctermbg=NONE gui=NONE      guifg=".color_9"  guibg=".color_bg
exe "hi! Character      cterm=NONE      ctermfg=11   ctermbg=NONE gui=NONE      guifg=".color_11" guibg=".color_bg
exe "hi! link String  Constant"
exe "hi! link Number  Character"
exe "hi! link Float   Number"
exe "hi! link Boolean Statement"

" variable names
exe "hi! Function       cterm=NONE      ctermfg=6    ctermbg=NONE gui=NONE      guifg=".color_6"  guibg=".color_bg
exe "hi! Identifier     cterm=NONE      ctermfg=14   ctermbg=NONE gui=NONE      guifg=".color_14" guibg=".color_bg

" statements
exe "hi! Statement      cterm=bold      ctermfg=5    ctermbg=NONE gui=bold      guifg=".color_5"  guibg=".color_bg
exe "hi! link Conditional Statement"
exe "hi! link Repeat      Statement"
exe "hi! link Label       Statement"
exe "hi! link Keyword     Statement"
exe "hi! link Exception   Statement"
exe "hi! link Operator    Normal"

" generic Preprocessor
exe "hi! PreProc        cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! link Include   PreProc"
exe "hi! link Define    PreProc"
exe "hi! link Macro     PreProc"
exe "hi! link PreCondit PreProc"

" types
exe "hi! Type           cterm=bold      ctermfg=13   ctermbg=NONE gui=bold      guifg=".color_13" guibg=".color_bg
"exe "hi! link Type Statement"
exe "hi! link Structure    Statement"
exe "hi! link StorageClass Statement"
exe "hi! link Typedef      Statement"

" special symbols
exe "hi! Delimiter      cterm=NONE      ctermfg=2    ctermbg=NONE gui=NONE      guifg=".color_2"  guibg=".color_bg
exe "hi! link Tag         Delimiter"
exe "hi! link Special     Character"
exe "hi! link SpecialChar Character"

" my custom groups
exe "hi! MembOperator   cterm=NONE      ctermfg=8    ctermbg=NONE gui=NONE      guifg=".color_8"  guibg=".color_bg
exe "hi! OtherType      cterm=NONE      ctermfg=12   ctermbg=NONE gui=NONE      guifg=".color_12" guibg=".color_bg
exe "hi! SpecialComment cterm=bold      ctermfg=15   ctermbg=NONE gui=bold      guifg=".color_15" guibg=".color_bg

" errors and warnings
exe "hi! MatchParen     cterm=bold      ctermfg=11   ctermbg=8    gui=bold      guifg=".color_11" guibg=".color_8
exe "hi! Error          cterm=bold      ctermfg=1    ctermbg=NONE gui=bold      guifg=".color_1"  guibg=".color_bg
exe "hi! ErrorMsg       cterm=NONE      ctermfg=1    ctermbg=NONE gui=NONE      guifg=".color_1"  guibg=".color_bg
exe "hi! Todo           cterm=bold      ctermfg=3    ctermbg=NONE gui=bold      guifg=".color_3"  guibg=".color_bg
exe "hi! WarningMsg     cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! SpellBad       cterm=underline ctermfg=1    ctermbg=NONE gui=underline guifg=".color_1"  guibg=".color_bg
exe "hi! SpellCap       cterm=underline ctermfg=3    ctermbg=NONE gui=underline guifg=".color_3"  guibg=".color_bg
exe "hi! underlined     cterm=underline ctermfg=4    ctermbg=NONE gui=underline guifg=".color_4"  guibg=".color_bg
exe "hi! Directory      cterm=NONE      ctermfg=10   ctermbg=NONE gui=NONE      guifg=".color_10" guibg=".color_bg
exe "hi! SpellLocal     cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! link SpellRare SpellLocal"

" visual elements
exe "hi! Search         cterm=reverse   ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! Visual         cterm=reverse   ctermfg=NONE ctermbg=NONE gui=reverse   guifg=".color_fg" guibg=".color_bg
exe "hi! SignColumn     cterm=NONE      ctermfg=NONE ctermbg=NONE gui=NONE      guifg=".color_fg" guibg=".color_bg
exe "hi! LineNr         cterm=NONE      ctermfg=0    ctermbg=NONE gui=NONE      guifg=".color_0"  guibg=".color_bg
exe "hi! CursorLineNr   cterm=NONE      ctermfg=NONE ctermbg=NONE gui=NONE      guifg=".color_fg" guibg=".color_bg
exe "hi! EndOfBuffer    cterm=NONE      ctermfg=0    ctermbg=NONE gui=NONE      guifg=".color_0"  guibg=".color_bg
exe "hi! StatusLine     cterm=NONE      ctermfg=7    ctermbg=8    gui=NONE      guifg=".color_7"  guibg=".color_8
exe "hi! StatusLineNC   cterm=NONE      ctermfg=NONE ctermbg=0    gui=NONE      guifg=".color_fg" guibg=".color_0
exe "hi! ColorColumn    cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! link IncSearch        Search"
exe "hi! link Folded           Comment"
exe "hi! link VertSplit        Comment"
exe "hi! link StatusLineTerm   StatusLine"
exe "hi! link StatusLineTermNC StatusLineNC"
exe "hi! link FoldColumn       EndOfBuffer"

" menus and messages
exe "hi! Question       cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! WildMenu       cterm=NONE      ctermfg=0    ctermbg=3    gui=NONE      guifg=".color_0"  guibg=".color_3
exe "hi! Pmenu          cterm=NONE      ctermfg=NONE ctermbg=0    gui=NONE      guifg=".color_fg" guibg=".color_0
exe "hi! PmenuSel       cterm=NONE      ctermfg=7    ctermbg=4    gui=NONE      guifg=".color_7"  guibg=".color_4
exe "hi! PmenuThumb     cterm=reverse   ctermfg=15   ctermbg=NONE gui=reverse   guifg=".color_15" guibg=".color_bg
exe "hi! link PmenuSbar  Pmenu"
exe "hi! link ModeMsg    OtherType"
exe "hi! link MoreMsg    ModeMsg"
exe "hi! link Conceal    LineNr"
exe "hi! link Ignore     Conceal"
exe "hi! link SpecialKey Conceal"
exe "hi! link NonText    Conceal"
