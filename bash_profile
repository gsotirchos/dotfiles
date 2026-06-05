#
# ~/.bash_profile
#

# shellcheck shell=bash disable=SC1090,SC1091

# env_before="$(env)"
# echo "SOURCED ~/.bash_profile"
# [[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'
# shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'

# set the locale to English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=100000
export HISTFILESIZE=100000

# determine OS
case "$(uname -s)" in
    Linux*)
        export OS="linux"
        if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
            export WSL=true
        else
            export WSL=false
        fi
        ;;
    Darwin*)
        export OS="macos"
        ;;
esac

if [[ "$OS" == "linux" ]]; then
    export TMPDIR="${HOME}/.tmp"
fi

if [[ "$OS" == "macos" ]]; then
    # increase max. open files limit
    ulimit -n 1024
fi

# homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# set dotfiles path
export DOTFILES="${HOME}/.dotfiles"
export MACOS_DOTFILES="${DOTFILES}"

# TIME ~60ms
# append extra paths from files to $PATH, $LIBRARY_PATH, etc.
if [[ -d "${DOTFILES}"/extra_paths ]]; then
    if [[ -d "${DOTFILES}"/extra_paths/common ]]; then
        source "${MACOS_DOTFILES}/etc/append_to_paths.sh" "${DOTFILES}/extra_paths/common"
    fi
    if [[ -d "${DOTFILES}/extra_paths/${OS}" ]]; then
        source "${MACOS_DOTFILES}/etc/append_to_paths.sh" "${DOTFILES}/extra_paths/${OS}"
    fi
fi

# NOTE: must be ran after appending the extra paths
export SHELL="$(which bash)"
if command -v "emacsclient" &> /dev/null; then
    export EDITOR="emacsclient --no-wait --create-frame --alternate-editor="
    export GIT_EDITOR="emacsclient --create-frame --alternate-editor="
    export VISUAL="emacsclient --create-frame --alternate-editor="
else
    export EDITOR="vim"
    export GIT_EDITOR="vim"
    export VISUAL="vim"
fi

# set cmake makefile generator, compiler, and standard
export CC="$(command -v gcc-11 || command -v clang)"
export CXX="$(command -v g++-11 || command -v clang++)"
export CXX_STD="c++17"
export CMAKE_PREFIX_PATH="${HOMEBREW_PREFIX}/opt/llvm"
export CMAKE_GENERATOR="$(
    command -v ninja &> /dev/null \
        && echo "Ninja" \
        || echo ""
)"
export CMAKE_EXPORT_COMPILE_COMMANDS=1

export BASH_PROFILE_SOURCED=1

if [[ $- == *i* ]]; then
    if [[ -f ~/.bashrc ]]; then
        source ~/.bashrc
    fi
fi

# env_after="$(env)"
# diff <(echo "$env_before") <(echo "$env_after") | grep [A-Z_0-9]+\=
# diff <(echo "$env_before") <(echo "$ensudo bash -c "$(declare -f); exec suv_after") | grep [a-z_]+\=
# time bash -i -c 'exit'
