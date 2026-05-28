#
# ~/.bash_profile
#

# shellcheck shell=bash disable=SC1090

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
export HISTSIZE=1000
export HISTFILESIZE=2000

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

# homebrew
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# set dotfiles paths
export DOTFILES="$(
    builtin cd "$(
        dirname "$(realpath "${BASH_SOURCE[0]}")"
    )" > /dev/null && pwd
)"


# set macos-DOTFILES path
if [[ -d "${HOME}/.macos-dotfiles" ]]; then
    export MACOS_DOTFILES="${DOTFILES}"
else
    export MACOS_DOTFILES="${HOME}/.macos-dotfiles"
fi

# TIME ~60ms
# append extra paths from files to $PATH, $LIBRARY_PATH, etc.
if [[ -d "${DOTFILES}"/extra_paths ]]; then
    source "${MACOS_DOTFILES}/etc/append_to_paths.sh" "${DOTFILES}/extra_paths"
fi

export SHELL="$(which bash)"
export EDITOR="emacsclient -cn"
export GIT_EDITOR="emacsclient -c"
export VISUAL="emacsclient -c"

if [[ "$OS" == "linux" ]]; then
    # export LD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}"
    export TMPDIR="${HOME}/.tmp"
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

if [[ $- == *i* ]]; then
    if [[ -f ~/.bashrc ]]; then
        source ~/.bashrc
    fi
fi

# env_after="$(env)"
# diff <(echo "$env_before") <(echo "$env_after") | grep [A-Z_0-9]+\=
# diff <(echo "$env_before") <(echo "$ensudo bash -c "$(declare -f); exec suv_after") | grep [a-z_]+\=
# time bash -i -c 'exit'
