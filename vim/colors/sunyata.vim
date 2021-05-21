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

let color_fg=color_7
let color_bg=color_0

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
exe "hi! link String Constant"
exe "hi! Character      cterm=NONE      ctermfg=11   ctermbg=NONE gui=NONE      guifg=".color_11" guibg=".color_bg
exe "hi! link Number Character"
exe "hi! link Boolean Statement"
exe "hi! link Float Number"

" variable names
exe "hi! Function       cterm=NONE      ctermfg=6    ctermbg=NONE gui=NONE      guifg=".color_6"  guibg=".color_bg
exe "hi! Identifier     cterm=NONE      ctermfg=14   ctermbg=NONE gui=NONE      guifg=".color_14"  guibg=".color_bg

" statements
exe "hi! Statement      cterm=bold      ctermfg=5    ctermbg=NONE gui=bold      guifg=".color_5"  guibg=".color_bg
exe "hi! link Conditional Statement"
exe "hi! link Repeat Statement"
exe "hi! link Label Statement"
exe "hi! link Operator Normal"
exe "hi! link Keyword Statement"
exe "hi! link Exception Statement"

" generic Preprocessor
exe "hi! PreProc        cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! link Include PreProc"
exe "hi! link Define PreProc"
exe "hi! link Macro PreProc"
exe "hi! link PreCondit PreProc"

" types
exe "hi! link Type Statement"
exe "hi! link StorageClass Type"
exe "hi! link Structure Type"
exe "hi! link Typedef Type"

" special symbols
exe "hi! Special        cterm=NONE      ctermfg=2    ctermbg=NONE gui=NONE      guifg=".color_2"  guibg=".color_bg
exe "hi! link SpecialChar Special"
exe "hi! link Tag Special"
exe "hi! Delimiter      cterm=bold      ctermfg=13   ctermbg=NONE gui=NONE      guifg=".color_13" guibg=".color_bg
exe "hi! SpecialComment cterm=bold      ctermfg=15   ctermbg=NONE gui=bold      guifg=".color_15" guibg=".color_bg

" my custom groups
exe "hi! MembOperator   cterm=NONE      ctermfg=8    ctermbg=NONE gui=NONE      guifg=".color_8"  guibg=".color_bg
exe "hi! OtherType      cterm=NONE      ctermfg=12   ctermbg=NONE gui=NONE      guifg=".color_12" guibg=".color_bg

exe "hi! Search         cterm=NONE      ctermfg=0    ctermbg=3    gui=NONE      guifg=".color_0"  guibg=".color_3
exe "hi! link IncSearch Search"
exe "hi! MatchParen     cterm=bold      ctermfg=3    ctermbg=8    gui=bold      guifg=".color_3"  guibg=".color_8
exe "hi! Error          cterm=bold      ctermfg=1    ctermbg=NONE gui=bold      guifg=".color_1"  guibg=".color_bg
exe "hi! ErrorMsg       cterm=NONE      ctermfg=1    ctermbg=NONE gui=NONE      guifg=".color_1"  guibg=".color_bg
exe "hi! Todo           cterm=bold      ctermfg=3    ctermbg=NONE gui=bold      guifg=".color_3"  guibg=".color_bg
exe "hi! WarningMsg     cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! SpellBad       cterm=underline ctermfg=1    ctermbg=NONE gui=underline guifg=".color_1"  guibg=".color_bg
exe "hi! SpellCap       cterm=underline ctermfg=3    ctermbg=NONE gui=underline guifg=".color_3"  guibg=".color_bg
exe "hi! SpellLocal     cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! link SpellRare SpellLocal"
exe "hi! underlined     cterm=underline ctermfg=4    ctermbg=NONE gui=underline guifg=".color_12" guibg=".color_bg
exe "hi! Ignore         cterm=NONE      ctermfg=5    ctermbg=NONE gui=NONE      guifg=".color_5"  guibg=".color_bg
exe "hi! Directory      cterm=NONE      ctermfg=10   ctermbg=NONE gui=NONE      guifg=".color_10" guibg=".color_bg

exe "hi! SignColumn     cterm=NONE      ctermfg=NONE ctermbg=NONE gui=NONE      guifg=".color_fg" guibg=".color_bg
exe "hi! Visual         cterm=reverse   ctermfg=NONE ctermbg=NONE gui=reverse   guifg=".color_fg" guibg=".color_bg
exe "hi! LineNr         cterm=NONE      ctermfg=8    ctermbg=NONE gui=NONE      guifg=".color_8"  guibg=".color_bg
exe "hi! CursorLineNr   cterm=NONE      ctermfg=NONE ctermbg=NONE gui=NONE      guifg=".color_fg" guibg=".color_bg
exe "hi! Folded   cterm=NONE      ctermfg=7    ctermbg=NONE    gui=NONE      guifg=".color_7"  guibg=".color_bg
exe "hi! EndOfBuffer    cterm=NONE      ctermfg=0    ctermbg=NONE gui=NONE      guifg=".color_0"  guibg=".color_bg
exe "hi! StatusLine     cterm=NONE      ctermfg=NONE ctermbg=8    gui=NONE      guifg=".color_fg" guibg=".color_8
exe "hi! StatusLineNC   cterm=NONE      ctermfg=0    ctermbg=8    gui=NONE      guifg=".color_7"  guibg=".color_8
exe "hi! ColorColumn    cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! link VertSplit Comment"
exe "hi! link StatusLineTerm StatusLine"
exe "hi! link StatusLineTermNC StatusLineNC"
exe "hi! link FoldColumn EndOfBuffer"

exe "hi! Question       cterm=NONE      ctermfg=3    ctermbg=NONE gui=NONE      guifg=".color_3"  guibg=".color_bg
exe "hi! WildMenu       cterm=NONE      ctermfg=0    ctermbg=3    gui=NONE      guifg=".color_0"  guibg=".color_3
exe "hi! link MoreMsg ModeMsg"
exe "hi! Pmenu          cterm=NONE      ctermfg=7    ctermbg=8    gui=NONE      guifg=".color_7" guibg=".color_8
exe "hi! PmenuSel       cterm=NONE      ctermfg=15   ctermbg=7    gui=NONE      guifg=".color_15" guibg=".color_7
exe "hi! PmenuThumb     cterm=reverse   ctermfg=15   ctermbg=NONE gui=reverse   guifg=".color_15" guibg=".color_bg
exe "hi! link PmenuSbar Pmenu"
exe "hi! link ModeMsg OtherType"
exe "hi! link Conceal Comment"
exe "hi! link SpecialKey Comment"
exe "hi! link NonText Comment"
