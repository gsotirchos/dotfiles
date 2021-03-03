#!/opt/pkg/bin/bash

#
# ${DOTFILES}/setup.sh
#

# dotfiles path
DOTFILES=$(\
    builtin cd "$(\
    dirname "$(realpath "${BASH_SOURCE[0]}")"\
    )" > /dev/null && pwd)

# prepare folders
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/spell
mkdir -vp ~/.config/lf
mkdir -vp ~/.local/bin
touch ~/.hushlogin

# make soft symlinks
echo "- Symlinking dotfiles (${DOTFILES})"
"${DOTFILES}"/bin/ln_dotfiles "${DOTFILES}"
ln -sfv "${DOTFILES}"/LaunchAgents/* ~/Library/LaunchAgents
ln -sfv "${DOTFILES}"/vim/*          ~/.vim
ln -sfv ~/.windows_dotfiles/lfrc     ~/.config/lf/lfrc

echo -e "\n!! Don't forget to load the .plist files!"

# setup julia
echo -e "\n- Setting up Julia"
"${DOTFILES}"/julia/setup-julia.sh
