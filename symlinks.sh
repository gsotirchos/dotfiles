#!/opt/pkg/bin/bash

#
# ~/.macos-dotfiles/symlinks.sh
#

# prepare folders
mkdir -vp ~/.config/ranger/colorschemes

# make soft symlinks
ln -sfv ~/.macos-dotfiles/inputrc                      ~/.inputrc
ln -sfv ~/.macos-dotfiles/bash_profile                 ~/.bash_profile
ln -sfv ~/.macos-dotfiles/vimrc                        ~/.vimrc
ln -sfv ~/.macos-dotfiles/config/ranger/*.*            ~/.config/ranger
ln -sfv ~/.macos-dotfiles/config/ranger/colorschemes/* ~/.config/ranger/colorschemes
