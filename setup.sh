#!/opt/pkg/bin/bash

#
# ${DOTFILES}/symlinks.sh
#

# dotfiles path
DOTFILES="$( dirname $( grealpath "${BASH_SOURCE}" ) )"

# prepare folders
mkdir -vp ~/.config/lf

# make soft symlinks
ln -sfv ${DOTFILES}/bin/*              ~/.bin
ln -sfv ${DOTFILES}/inputrc            ~/.inputrc
ln -sfv ${DOTFILES}/bash_profile       ~/.bash_profile
ln -sfv ${DOTFILES}/vimrc              ~/.vimrc
ln -sfv ${DOTFILES}/LaunchAgents/com.* ~/Library/LaunchAgents
ln -sfv ~/.freebsd_dotfiles/vim/*      ~/.vim
ln -sfv ~/.windows_dotfiles/lfrc       ~/.config/lf/lfrc

echo -e "\nDon't forget to load the .plist files!"
