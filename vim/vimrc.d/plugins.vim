let g:polyglot_disabled = ['autoindent', 'sensible']

" ---

set rtp+=$HOME/.vim/bundle/Vundle.vim

call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
"Plugin 'neoclide/coc.nvim', {'branch': 'release'}
Plugin 'github/copilot.vim'
Plugin 'sheerun/vim-polyglot'
Plugin 'lervag/wiki.vim'
Plugin 'tpope/vim-rsi'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-unimpaired'
"Plugin 'wikitopian/hardmode'
"Plugin 'gsotirchos/copilot-chat.vim'  " TODO: 'DanBradbury/copilot-chat.vim'
call vundle#end()
