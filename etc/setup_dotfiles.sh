#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2155
# shellcheck source-path=.dotfiles

# styling
BR_TEXT='\033[1;97m'
TEXT='\033[0m'

# check for `realpath` command
if ! command -v "realpath" &> /dev/null; then
    echo -e "${BR_TEXT}Error: \`realpath\` command could not be found. Aborted${TEXT}"
    exit
fi

# dotfiles path (directory containing this sourced script)
DOTFILES="$(
    builtin cd "$(
        realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
    )" > /dev/null && pwd
)"

# prepare user folder
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/spell
mkdir -vp ~/.vim/words
mkdir -vp ~/.vim/tags
mkdir -vp ~/.conda
mkdir -vp ~/.local/bin
touch ~/.hushlogin

# make soft symlinks
echo -e "${BR_TEXT}- Symlinking dotfiles (${DOTFILES})${TEXT}"
source "${DOTFILES}"/etc/symlink_dotfiles.sh "${DOTFILES}" "${HOME}/." # ~/.dotfiles/* -> ~/.*
ln -sfv "${DOTFILES}/vim/"* ~/.vim      # ~/.dotfiles/vim/* -> ~/.vim/*
ln -sfv "${DOTFILES}/conda/"* ~/.conda  # ~/.dotfiles/vim/* -> ~/.vim/*

# setup launch daemons and launch agents
if command -v "launchctl" &> /dev/null; then
    echo -e "${BR_TEXT}\n- Setting up LaunchDaemons and LaunchAgents${TEXT}"
    source "${DOTFILES}/etc/setup_launch_daemons_agents.sh" "${DOTFILES}/Library/LaunchDaemons" /Library/LaunchDaemons
    source "${DOTFILES}/etc/setup_launch_daemons_agents.sh" "${DOTFILES}/Library/LaunchAgents" ~/Library/LaunchAgents
fi

# setup vundle
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
    echo -e "${BR_TEXT}\n- Couldn't locate ~/.vim/bundle/Vundle.vim, setting up...${TEXT}"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
fi

# setup julia
if command -v "julia" &> /dev/null; then
    echo -e "${BR_TEXT}\n- Setting up Julia${TEXT}"
    "${DOTFILES}"/julia/setup-julia
fi
