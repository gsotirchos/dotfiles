#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2155
# shellcheck source-path=.dotfiles

#
# ${DOTFILES}/setup.sh
#

# styling
BR_TEXT='\033[1;97m'
TEXT='\033[0m'

# check for `realpath` command
if ! command -v realpath &> /dev/null; then
    echo -e "${BR_TEXT}Error: \`realpath\` command could not be found. Aborted${TEXT}"
    exit
fi

# dotfiles path
DOTFILES="$(
    builtin cd "$(
        dirname "$(realpath "${BASH_SOURCE[0]}")"
    )" > /dev/null && pwd
)"

# prepare folders
mkdir -vp ~/.vim/undo
mkdir -vp ~/.vim/spell
mkdir -vp ~/.vim/words
mkdir -vp ~/.vim/tags
mkdir -vp ~/.local/bin
touch ~/.hushlogin

# make soft symlinks
echo -e "${BR_TEXT}- Symlinking dotfiles (${DOTFILES})${TEXT}"
source "${DOTFILES}/etc/ln_dotfiles.sh" "${DOTFILES}" "${HOME}/." # ~/.*
ln -sfv "${DOTFILES}/vim/"* ~/.vim                                # ~/.vim/

# setup launch daemons and launch agents
echo -e "${BR_TEXT}\n- Setting up LaunchDaemons and LaunchAgents${TEXT}"
source "${DOTFILES}/etc/setup_launch_daemons.sh" "${DOTFILES}/LaunchDaemons" # /Library/LaunchDaemons/
source "${DOTFILES}/etc/setup_launch_agents.sh" "${DOTFILES}/LaunchAgents"   # ~/.Library/LaunchAgents/

# setup vundle
if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
    echo -e "${BR_TEXT}\n- Couldn't locate ~/.vim/bundle/Vundle.vim, setting up...${TEXT}"
    git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
    vim +PluginInstall +qall
fi

# setup julia
if command -v "julia" &> /dev/null; then
    echo -e "${BR_TEXT}\n- Setting up Julia${TEXT}"
    source "${DOTFILES}"/julia/setup-julia.sh
fi
