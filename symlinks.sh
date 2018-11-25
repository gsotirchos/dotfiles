#!/opt/pkg/bin/bash

#
# ~/.macos-dotfiles/symlinks.sh
#

# dotfiles path
dotfiles="/Users/$USER/.macos-dotfiles"

# prepare folders
mkdir -vp ~/.config/ranger/colorschemes
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/after/syntax

# make soft symlinks
ln -sfv $dotfiles/inputrc                      ~/.inputrc
ln -sfv $dotfiles/bash_profile                 ~/.bash_profile
ln -sfv $dotfiles/vimrc                        ~/.vimrc
ln -sfv $dotfiles/vim/after/syntax/tex.vim     ~/.vim/after/syntax/tex.vim
ln -sfv $dotfiles/config/ranger/*.*            ~/.config/ranger
ln -sfv $dotfiles/config/ranger/colorschemes/* ~/.config/ranger/colorschemes
