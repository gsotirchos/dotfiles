#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2155
# shellcheck source-path=.dotfiles

#
# ${MACOS_DOTFILES)}/setup.sh
#

main() {
    # styling
    BR_TEXT='\033[1;97m'
    TEXT='\033[0m'

    # check for `realpath` command
    if ! command -v "realpath" &> /dev/null; then
        echo -e "${BR_TEXT}Error: \`realpath\` command could not be found. Aborted${TEXT}"
        exit
    fi

    # dotfiles path (directory containing this sourced script)
    MACOS_DOTFILES="$(
        builtin cd "$(
            dirname "$(realpath "${BASH_SOURCE[0]}")"
        )" > /dev/null && pwd
    )"

    # prepare user folder
    mkdir -vp ~/.vim/undo
    mkdir -vp ~/.vim/spell
    mkdir -vp ~/.vim/words
    mkdir -vp ~/.vim/tags
    mkdir -vp ~/.local/bin
    touch ~/.hushlogin

    # make soft symlinks
    echo -e "${BR_TEXT}- Symlinking dotfiles (${MACOS_DOTFILES})${TEXT}"
    source "${MACOS_DOTFILES}/etc/symlink_dotfiles.sh" "${MACOS_DOTFILES}" "${HOME}/." # ~/.dotfiles/* -> ~/.*
    ln -sfv "${MACOS_DOTFILES}/vim/"* ~/.vim                                           # ~/.dotfiles/vim/* -> ~/.vim/*

    # setup launch daemons and launch agents
    if command -v "launchd" &> /dev/null; then
        echo -e "${BR_TEXT}\n- Setting up LaunchDaemons and LaunchAgents${TEXT}"
        source "${MACOS_DOTFILES}/etc/setup_launch_daemons.sh" "${MACOS_DOTFILES}/LaunchDaemons" # /Library/LaunchDaemons/
        source "${MACOS_DOTFILES}/etc/setup_launch_agents.sh" "${MACOS_DOTFILES}/LaunchAgents"   # ~/.Library/LaunchAgents/
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
        source "${MACOS_DOTFILES}"/julia/setup-julia.sh
    fi

}

main "$@"
unset main
