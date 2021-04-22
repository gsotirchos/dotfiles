#!/usr/bin/env bash

#
# ${DOTFILES}/setup.sh
#

BRIGHT_COLOR='\033[0;97m'
NORMAL_COLOR='\033[0m'

# check for `realpath` command
if ! command -v realpath &> /dev/null; then
    echo -e "${BRIGHT_COLOR}Error: \`realpath\` command could not be found. Aborted${NORMAL_COLOR}"
    exit
fi

# dotfiles path
DOTFILES=$(\
    builtin cd "$(\
        dirname "$(realpath ${BASH_SOURCE[0]})"\
    )" > /dev/null && pwd)

# prepare folders
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/spell
mkdir -vp ~/.vim/words
mkdir -vp ~/.local/bin
touch ~/.hushlogin
sudo chown root:wheel .dotfiles/LaunchDaemons/*

# make soft symlinks
echo -e "${BRIGHT_COLOR}- Symlinking dotfiles (${DOTFILES})${NORMAL_COLOR}"
"${DOTFILES}"/bin/ln_dotfiles "${DOTFILES}" "${HOME}/."
ln -sfv "${DOTFILES}"/vim/* ~/.vim

# setup launch daemons
for plist_file in "${HOME}/.dotfiles/LaunchDaemons/"*.plist; do
    sudo ln -sfv "${plist_file}"\
        "/Library/LaunchDaemons/$(basename ${plist_file})"
    sudo chown root:wheel\
        "/Library/LaunchDaemons/$(basename ${plist_file})"
    sudo launchctl load -w\
        "/Library/LaunchDaemons/$(basename ${plist_file})"
done

# setup julia
if command -v "julia" &> /dev/null; then
    echo -e "${BRIGHT_COLOR}\n- Setting up Julia${NORMAL_COLOR}"
    "${DOTFILES}"/julia/setup-julia.sh
fi
