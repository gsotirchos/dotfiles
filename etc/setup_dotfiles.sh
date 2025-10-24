# shellcheck disable=SC1090,SC2155
# shellcheck source-path=.dotfiles

main() {
    # text styling
    local bright_style='\033[1;97m'
    local normal_style='\033[0m'

    # check for `realpath` command
    if ! command -v "realpath" &> /dev/null; then
        echo -e "${bright_style}Error: \`realpath\` command could not be found. Aborted${normal_style}"
        exit
    fi

    # dotfiles path (directory containing this sourced script)
    local dotfiles="$(
        builtin cd "$(
            realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
        )" > /dev/null && pwd
    )"

    # prepare user folder
    mkdir -vp ~/.vim/undo
    mkdir -vp ~/.vim/spell
    mkdir -vp ~/.vim/tags
    mkdir -vp ~/.config/ghostty
    mkdir -vp ~/.conda
    mkdir -vp ~/.local/bin
    mkdir -v ~/Zotero/translators
    touch ~/.hushlogin

    # make soft symlinks
    echo -e "${bright_style}- Symlinking dotfiles (${dotfiles})${normal_style}"
    source "${dotfiles}"/etc/symlink_files.sh "${dotfiles}" "${HOME}/."  # ~/.dotfiles/* -> ~/.*
    ln -sfv "${dotfiles}"/emacs.d/*            ~/.emacs.d
    ln -sfv "${dotfiles}"/vim/*                ~/.vim
    ln -sfv "${dotfiles}"/conda/*              ~/.conda
    ln -sfv "${dotfiles}"/config/ghostty/*     ~/.config/ghostty
    ln -sfv "${dotfiles}"/config/starship.toml ~/.config/starship.toml
    ln -sfv "${dotfiles}"/Zotero/translators/* ~/Zotero/translators

    # setup launch daemons and launch agents
    if command -v "launchctl" &> /dev/null; then
        echo -e "${bright_style}\n- Setting up LaunchDaemons and LaunchAgents${normal_style}"
        source "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchDaemons" /Library/LaunchDaemons
        source "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchAgents" ~/Library/LaunchAgents
    fi

    # setup vundle
    if [[ ! -d ~/.vim/bundle/Vundle.vim ]]; then
        echo -e "${bright_style}\n- Couldn't locate ~/.vim/bundle/Vundle.vim, setting up...${normal_style}"
        git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
        vim +PluginInstall +qall
    fi

    # setup julia
    if command -v "julia" &> /dev/null; then
        echo -e "${bright_style}\n- Setting up Julia${normal_style}"
        "${dotfiles}"/julia/setup-julia
    fi
}

main "$@"
unset main
