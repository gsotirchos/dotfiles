#!/usr/bin/env bash
# shellcheck disable=SC2155
set -euo pipefail

main() {
    # text styling
    local bright_style='\033[1m'
    local normal_style='\033[0m'

    # check for required commands
    for cmd in realpath stow; do
        if ! command -v "${cmd}" &> /dev/null; then
            echo -e "${bright_style}Error: \`${cmd}\` command could not be found. Aborted${normal_style}" >&2
            exit 1
        fi
    done

    # dotfiles path (directory containing this script)
    local dotfiles="$(
        builtin cd "$(
            realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
        )" > /dev/null && pwd
    )"

    # Determine OS
    local os="linux"
    if [[ "$(uname -s)" == "Darwin" ]]; then
        os="macos"
    fi

    # init submodules (vim plugins)
    echo -e "${bright_style}- Initializing submodules${normal_style}"
    git -C "${dotfiles}" submodule update --init --recursive

    # prepare parent dirs that Stow won't auto-create outside its tree
    mkdir -p \
        ~/.local/bin \
        ~/.vim/{undo,spell,tags} \
        ~/.config \
        ~/.conda \
        ~/Zotero
    if [[ "${os}" == "linux" ]]; then
        mkdir -p ~/.local/share/fonts
    fi
    touch ~/.hushlogin

    # remove any leftover symlinks from the previous (symlink_files.sh-based) setup
    # so that stow has a clean target on machines being migrated.
    echo -e "${bright_style}- Cleaning up legacy symlinks${normal_style}"
    local legacy=(
        ~/.bashrc ~/.bash_aliases ~/.bash_profile ~/.inputrc ~/.completion_dirs
        ~/.gitconfig ~/.gitignore
        ~/.vim ~/.emacs.d ~/.conda
        ~/.config/starship.toml ~/.config/ghostty ~/.config/opencode
        ~/.config/redshift.conf
        ~/.clang-format ~/.clang-tidy ~/.clangd ~/.cmake-format.yaml
        ~/.chktexrc ~/.latexindent.yaml ~/.indentconfig.yaml
        ~/.shellcheckrc ~/.markdownlint.json ~/.proselintrc ~/.pyproject.toml
        ~/.op_secrets
        ~/.README.md ~/.AGENTS.md ~/.CLAUDE.md ~/.LICENSE ~/.Doxyfile ~/.PlatformIO_Makefile
    )
    local f
    for f in "${legacy[@]}"; do
        [[ -L "${f}" ]] && rm -v "${f}"
    done
    unset f

    # stow the common packages
    echo -e "${bright_style}- Stowing dotfiles${normal_style}"
    local common=(
        bash git vim emacs conda starship ghostty opencode zotero
        clang cmake latex linters op
    )
    stow -d "${dotfiles}/packages" -t "${HOME}" -R "${common[@]}"

    # OS-specific
    if [[ "${os}" == "linux" ]]; then
        stow -d "${dotfiles}/packages" -t "${HOME}" -R redshift
        # autostart and gtk packages exist but are opt-in:
        #   stow -d "${dotfiles}/packages" -t "${HOME}" -R autostart gtk
    fi

    # LaunchDaemons / LaunchAgents (macOS) — kept separate from Stow because
    # launchd expects copied (not symlinked) system daemons and needs sudo +
    # launchctl bootstrap to activate them.
    if [[ "${os}" == "macos" ]] && command -v launchctl &> /dev/null; then
        echo -e "${bright_style}- Setting up LaunchDaemons and LaunchAgents${normal_style}"
        "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchDaemons" /Library/LaunchDaemons
        "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchAgents"  ~/Library/LaunchAgents
    fi
}

main "$@"
unset main
