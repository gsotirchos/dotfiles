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
        ~/.config/pixi \
        ~/.conda \
        ~/.claude \
        ~/Zotero
    if [[ "${os}" == "linux" ]]; then
        mkdir -p ~/.local/share/fonts
    fi
    touch ~/.hushlogin

    # remove any leftover symlinks from the previous (symlink_files.sh-based) setup
    # so that stow has a clean target on machines being migrated.
    echo -e "${bright_style}- Cleaning up legacy symlinks${normal_style}"
    local legacy=(
        ~/.bashrc ~/.bash_aliases ~/.bash_profile ~/.profile ~/.inputrc ~/.completion_dirs
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

    mkdir -p ~/.emacs.d

    # stow the common packages
    echo -e "${bright_style}- Stowing dotfiles${normal_style}"
    local common=(
        bash git vim emacs ghostty starship op conda linters claude
        opencode pixi clang cmake latex zotero
    )
    local ignore=()
    [[ "${os}" == "macos" ]] && ignore=(--ignore='^\.profile$')
    stow -vd "${dotfiles}/packages" -t "${HOME}" ${ignore[@]+"${ignore[@]}"} -R "${common[@]}"

    # OS-specific overrides layered on top of shared packages (e.g. ghostty)
    stow -vd "${dotfiles}/packages" -t "${HOME}" -R "ghostty-${os}"

    # OS-specific
    if [[ "${os}" == "linux" ]]; then
        local dmi_product
        dmi_product=$(cat /sys/devices/virtual/dmi/id/product_name 2> /dev/null)
        if [[ "${dmi_product}" == "iMac14,1" ]]; then
            stow -vd "${dotfiles}/packages" -t "${HOME}" -R autostart
        fi
        # stow -vd "${dotfiles}/packages" -t "${HOME}" -R redshift

        # keyd config lives under /etc (system path), so it is stowed
        # separately from the HOME-targeted packages, and only when keyd
        # is installed.
        if command -v keyd &> /dev/null; then
            echo -e "${bright_style}- Stowing keyd config (/etc/keyd)${normal_style}"
            sudo mkdir -p /etc/keyd
            sudo stow -vd "${dotfiles}/packages" -t /etc -R keyd
            sudo systemctl restart keyd 2> /dev/null || true
        fi

        if [[ -f "${dotfiles}/config/dconf/user.conf" ]] \
            && { [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; }; then
            echo -e "${bright_style}- Importing GNOME dconf settings${normal_style}"
            bash "${dotfiles}/bin/linux/dconf-import"
        fi

        local ff_base="${XDG_CONFIG_HOME:-${HOME}/.config}/mozilla/firefox"
        [[ -f "${ff_base}/profiles.ini" ]] || ff_base="${HOME}/.mozilla/firefox"
        if [[ -f "${ff_base}/profiles.ini" ]]; then
            local ff_rel=$(sed -n '/^\[Install/,/^$/s/^Default=//p' "${ff_base}/profiles.ini" | head -1)
            if [[ -n "${ff_rel}" && -d "${ff_base}/${ff_rel}" ]]; then
                echo -e "${bright_style}- Stowing Firefox custom keyboard shortcuts${normal_style}"
                rm -f "${ff_base}/${ff_rel}/customKeys.json"
                stow -vd "${dotfiles}/packages" -t "${ff_base}/${ff_rel}" -R firefox
            fi
        fi
    fi

    # LaunchDaemons / LaunchAgents (macOS) — kept separate from Stow because
    # launchd expects copied (not symlinked) system daemons and needs sudo +
    # launchctl bootstrap to activate them.
    if [[ "${os}" == "macos" ]] && command -v launchctl &> /dev/null; then
        echo -e "${bright_style}- Setting up LaunchDaemons and LaunchAgents${normal_style}"
        "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchDaemons" /Library/LaunchDaemons
        "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchAgents" ~/Library/LaunchAgents
    fi
}

main "$@"
unset main
