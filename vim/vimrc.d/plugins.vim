let g:polyglot_disabled = ['autoindent', 'sensible']

" ---

set rtp+=$HOME/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plugin 'github/copilot.vim'
"Plugin 'gsotirchos/copilot-chat.vim'  " TODO: 'DanBradbury/copilot-chat.vim'
Plugin 'tpope/vim-rsi'
Plugin 'scrooloose/nerdcommenter'
"Plugin 'airblade/vim-gitgutter'  " TODO: set up
Plugin 'sheerun/vim-polyglot'
Plugin 'bfrg/vim-cpp-modern'
Plugin 'vim-python/python-syntax'
Plugin 'lervag/vimtex'  " TODO: coc-vimtex?
"Plugin 'preservim/vim-markdown'  " TODO: coc-markdownlint?
"Plugin 'vim-scripts/DoxygenToolkit.vim'
call vundle#end()
