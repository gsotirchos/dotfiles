let g:polyglot_disabled = ['autoindent', 'sensible']

" set the runtime path to include Vundle and initialize
set rtp+=$HOME/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"" plugins start here
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
"Plugin 'dense-analysis/ale'
Plugin 'github/copilot.vim'
"Plugin 'DanBradbury/copilot-chat.vim'  " TODO
Plugin 'gsotirchos/copilot-chat.vim'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-rsi'
"Plugin 'airblade/vim-gitgutter'  " TODO
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-easytags'
Plugin 'sheerun/vim-polyglot'
Plugin 'bfrg/vim-cpp-modern'
Plugin 'vim-python/python-syntax'
Plugin 'lervag/vimtex'
"Plugin 'preservim/vim-markdown'
"Plugin 'vim-scripts/DoxygenToolkit.vim'
"Plugin 'adimit/prolog.vim'
"Plugin 'PontusPersson/pddl.vim'
"Plugin 'neovimhaskell/haskell-vim'
"Plugin 'JuliaEditorSupport/julia-vim'
"Plugin 'keith/swift.vim'
"Plugin 'peterhoeg/vim-qml'
"Plugin 'PProvost/vim-ps1'
"Plugin 'yuezk/vim-js'

"" plugins end here
call vundle#end()  " required

