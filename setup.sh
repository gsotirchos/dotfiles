#!/usr/bin/env bash

BRIGHT_COLOR='\033[0;97m'
NORMAL_COLOR='\033[0m'

#
# ${DOTFILES}/setup.sh
#

# check for `realpath` command
if ! command -v realpath &> /dev/null; then
    echo -e "${BRIGHT_COLOR}Error: \`realpath\` command could not be found. Aborted${NORMAL_COLOR}"
    exit
fi

# dotfiles path
DOTFILES=$(\
    builtin cd "$(\
    dirname "$(realpath "${BASH_SOURCE[0]}")"\
    )" > /dev/null && pwd)

# prepare folders
mkdir -vp ~/Library/LaunchAgents
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/spell
mkdir -vp ~/.config/lf
mkdir -vp ~/.local/bin
touch ~/.hushlogin

# make soft symlinks
echo -e "${BRIGHT_COLOR}- Symlinking dotfiles (${DOTFILES})${NORMAL_COLOR}"
"${DOTFILES}"/bin/ln_dotfiles "${DOTFILES}"
ln -sfv "${DOTFILES}"/LaunchAgents/* ~/Library/LaunchAgents
ln -sfv "${DOTFILES}"/vim/*          ~/.vim
ln -sfv ~/.windows_dotfiles/lfrc     ~/.config/lf/lfrc

echo -e "${BRIGHT_COLOR}\n!! Don't forget to load the .plist files!${NORMAL_COLOR}"

# setup julia
if command -v "julia" &> /dev/null; then
    echo -e "${BRIGHT_COLOR}\n- Setting up Julia${NORMAL_COLOR}"
    "${DOTFILES}"/julia/setup-julia.sh
fi
