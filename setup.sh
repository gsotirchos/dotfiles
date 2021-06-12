#!/usr/bin/env bash

#
# ${DOTFILES}/setup.sh
#

# styling
BR_TEXT='\033[0;97m'
DEF_TEXT='\033[0m'

# check for `realpath` command
if ! command -v realpath &> /dev/null; then
    echo -e "${BR_TEXT}Error: \`realpath\` command could not be found. Aborted${DEF_TEXT}"
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
mkdir -vp ~/.vim/tags
mkdir -vp ~/.local/bin
touch ~/.hushlogin

# make soft symlinks
echo -e "${BR_TEXT}- Symlinking dotfiles (${DOTFILES})${DEF_TEXT}"
source "${DOTFILES}/etc/ln_dotfiles.sh" "${DOTFILES}" "${HOME}/."  # ~/.*
ln -sfv "${DOTFILES}/vim/"* ~/.vim  # ~/.vim/*

# setup launch daemons and launch agents
source "${DOTFILES}/etc/setup_launch_daemons.sh" "${DOTFILES}/LaunchDaemons"
source "${DOTFILES}/etc/setup_launch_agents.sh" "${DOTFILES}/LaunchAgents"

# setup vundle
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
    echo -e "${BR_TEXT}- Couldn't locate ~/.vim/bundle/Vundle.vim, setting up...${DEF_TEXT}"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
fi

# setup julia
if command -v "julia" &> /dev/null; then
    echo -e "${BR_TEXT}\n- Setting up Julia${DEF_TEXT}"
    "${DOTFILES}"/julia/setup-julia.sh
fi
