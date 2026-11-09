#!/usr/bin/env bash
set -euo pipefail

# text styling
bright_style='\033[1m'
normal_style='\033[0m'

# check for required commands
for cmd in realpath jq; do
    if ! command -v "${cmd}" &> /dev/null; then
        echo -e "${bright_style}Error: \`${cmd}\` command could not be found. Aborted${normal_style}" >&2
        exit 1
    fi
done

# dotfiles path (directory containing this script)
dotfiles="$(
    builtin cd "$(
        realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
    )" > /dev/null && pwd
)"

# Determine OS
os="linux"
if [[ "$(uname -s)" == "Darwin" ]]; then
    os="macos"
fi

# init submodules (vim plugins)
echo -e "${bright_style}- Initializing submodules${normal_style}"
git -C "${dotfiles}" submodule update --init --recursive

# remove any leftover symlinks from the previous (symlink_files.sh-based) setup
# so that stow has a clean target on machines being migrated.
echo -e "${bright_style}- Cleaning up legacy symlinks${normal_style}"
legacy=(
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
for f in "${legacy[@]}"; do
    [[ -L "${f}" ]] && rm -v "${f}"
done
unset f

echo -e "${bright_style}- Cloning Claude plugins${normal_style}"
"${dotfiles}/etc/setup_claude_plugins.sh" \
    "${dotfiles}/packages/claude/.claude/settings.json" \
    ~/.local/src/claude-plugins

# opencode plugins: install local plugin dependencies
for plugin_dir in "${dotfiles}"/packages/opencode/.config/opencode/plugins/*/; do
    [[ -f "${plugin_dir}package.json" ]] || continue
    echo -e "${bright_style}- Installing OpenCode plugin deps: $(basename "${plugin_dir}")${normal_style}"
    if command -v bun &> /dev/null; then
        (cd "${plugin_dir}" && bun install)
    elif command -v npm &> /dev/null; then
        (cd "${plugin_dir}" && npm install --no-audit --no-fund)
    fi
done

if [[ "${os}" == "linux" && -f "${dotfiles}/config/dconf/user.conf" ]] \
    && { [[ -n "${DISPLAY:-}" ]] || [[ -n "${WAYLAND_DISPLAY:-}" ]]; }; then
    echo -e "${bright_style}- Importing GNOME dconf settings${normal_style}"
    bash "${dotfiles}/bin/linux/dconf-import"
fi

if [[ "${os}" == "macos" ]]; then
    echo -e "${bright_style}- Importing macOS defaults${normal_style}"
    bash "${dotfiles}/bin/macos/defaults-import"
    killall Finder
fi

# steps that need sudo come last, so the prompt comes after everything else
"${dotfiles}/bin/stow-dotfiles"

# LaunchDaemons / LaunchAgents (macOS) — kept separate from Stow because
# launchd expects copied (not symlinked) system daemons and needs sudo +
# launchctl bootstrap to activate them.
if [[ "${os}" == "macos" ]] && command -v launchctl &> /dev/null; then
    echo -e "${bright_style}- Setting up LaunchDaemons and LaunchAgents${normal_style}"
    "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchAgents" ~/Library/LaunchAgents
    "${dotfiles}/etc/setup_launch_daemons_agents.sh" "${dotfiles}/Library/LaunchDaemons" /Library/LaunchDaemons
fi
