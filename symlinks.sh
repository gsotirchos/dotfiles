#!/opt/pkg/bin/bash

#
# ~/.macos-dotfiles/symlinks.sh
#

# dotfiles path
DOTFILES="/Users/$USER/.macos-dotfiles"

# prepare folders
mkdir -vp ~/.config/ranger/colorschemes
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/after/syntax

# make soft symlinks
ln -sfv $DOTFILES/bin/*                        ~/.bin
ln -sfv $DOTFILES/inputrc                      ~/.inputrc
ln -sfv $DOTFILES/bash_profile                 ~/.bash_profile
ln -sfv $DOTFILES/vimrc                        ~/.vimrc
ln -sfv $DOTFILES/vim/after/syntax/tex.vim     ~/.vim/after/syntax/tex.vim
ln -sfv $DOTFILES/config/ranger/*.*            ~/.config/ranger
ln -sfv $DOTFILES/config/ranger/colorschemes/* ~/.config/ranger/colorschemes
