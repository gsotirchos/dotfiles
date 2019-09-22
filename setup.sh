#!/opt/pkg/bin/bash

#
# ${DOTFILES}/symlinks.sh
#

# dotfiles path
DOTFILES="$( dirname $( grealpath "$0" ) )"

# prepare folders
mkdir -vp ~/.config/ranger/colorschemes
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/after/syntax

# make soft symlinks
ln -sfv ${DOTFILES}/bin/*                    ~/.bin
ln -sfv ${DOTFILES}/inputrc                  ~/.inputrc
ln -sfv ${DOTFILES}/bash_profile             ~/.bash_profile
ln -sfv ${DOTFILES}/vimrc                    ~/.vimrc
ln -sfv ${DOTFILES}/vim/after/syntax/tex.vim ~/.vim/after/syntax/tex.vim
#ln -sfv ${DOTFILES}/config/ranger/*.*            ~/.config/ranger
#ln -sfv ${DOTFILES}/config/ranger/colorschemes/* ~/.config/ranger/colorschemes
ln -sfv ${DOTFILES}/LaunchAgents/com.*       ~/Library/LaunchAgents

echo -e "\nDon't forget to load the .plist files!"
