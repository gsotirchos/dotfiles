#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2155
# shellcheck source-path=.dotfiles
set -euo pipefail

main() {
    # text styling
    local bright_style='\033[1m'
    local normal_style='\033[0m'

    # check for `realpath` command
    if ! command -v "realpath" &> /dev/null; then
        echo -e "${bright_style}Error: \`realpath\` command could not be found. Aborted${normal_style}"
        exit 1
    fi

    # dotfiles path (directory containing this sourced script)
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

    # prepare common folders
    mkdir -vp \
        ~/.local/bin \
        ~/.vim/{undo,spell,tags} \
        ~/.config/{ghostty,opencode} \
        ~/.conda \
        ~/Zotero/translators

    # prepare OS-specific folders
    if [[ "${os}" == "macos" ]]; then
        echo -n
    elif [[ "${os}" == "linux" ]]; then
        mkdir -vp \
            ~/.config/gtk-3.0 \
            ~/.config/autostart \
            ~/.local/share/fonts
    fi
    touch ~/.hushlogin

    # make soft symlinks
    echo -e "${bright_style}- Symlinking dotfiles (${dotfiles})${normal_style}"
    "${dotfiles}/etc/symlink_files.sh" "${dotfiles}" "${HOME}/." # ~/.dotfiles/* -> ~/.*
    ln -sfv "${dotfiles}"/.gitignore ~/.gitignore
    ln -sfv "${dotfiles}"/emacs.d/* ~/.emacs.d
    ln -sfv "${dotfiles}"/vim/* ~/.vim
    ln -sfv "${dotfiles}"/conda/* ~/.conda
    ln -sfv "${dotfiles}"/config/starship.toml ~/.config/starship.toml
    ln -sfv "${dotfiles}"/config/ghostty/* ~/.config/ghostty
    ln -sfv "${dotfiles}"/config/opencode/* ~/.config/opencode
    ln -sfv "${dotfiles}"/Zotero/translators/* ~/Zotero/translators

    # OS-specific symlinks
    if [[ "${os}" == "macos" ]]; then
        echo -n
    elif [[ "${os}" == "linux" ]]; then
        ln -sfv "${dotfiles}/config/redshift.conf" ~/.config/redshift.conf
        # ln -sfv "${dotfiles}/config/gtk-3.0/gtk.css" ~/.config/gtk-3.0/gtk.css
        # ln -sfv "${dotfiles}/config/autostart/"* ~/.config/autostart
        # ln -sfv "${dotfiles}/fonts/"*/*.otb ~/.local/share/fonts
    fi

    # setup launch daemons and launch agents
    if [[ "${os}" == "macos" ]] && command -v "launchctl" &> /dev/null; then
        echo -e "${bright_style}\n- Setting up LaunchDaemons and LaunchAgents${normal_style}"
        "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchDaemons" /Library/LaunchDaemons
        "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchAgents" ~/Library/LaunchAgents
    fi

    # setup git hooks
    echo -e "${bright_style}\n- Setting up Git hook${normal_style}"
    git -C "${dotfiles}" config core.hooksPath etc/hooks

    # patch Ghostty Modus themes
    if [[ "${os}" == "macos" ]] && [[ -x "${dotfiles}/etc/patch_modus.py" ]]; then
        "${dotfiles}/etc/patch_modus.py"
    fi
}

main "$@"
unset main
