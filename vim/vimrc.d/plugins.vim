let g:polyglot_disabled = ['autoindent', 'sensible']

" ---

set rtp+=$HOME/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'vimwiki/vimwiki'
Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plugin 'github/copilot.vim'
Plugin 'sheerun/vim-polyglot'
Plugin 'scrooloose/nerdcommenter'
Plugin 'tpope/vim-rsi'
"Plugin 'gsotirchos/copilot-chat.vim'  " TODO: 'DanBradbury/copilot-chat.vim'
"Plugin 'airblade/vim-gitgutter'  " TODO: set up
"Plugin 'vim-scripts/DoxygenToolkit.vim'
call vundle#end()
