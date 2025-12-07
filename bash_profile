#
# ~/.bash_profile
#

# shellcheck disable=SC1090

# echo "SOURCED ~/.bash_profile"
# [[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'
# shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'

# export env_before="$(env)"

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
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# set dotfiles path
dotfiles="$( \
    builtin cd "$( \
        dirname "$(realpath "${BASH_SOURCE[0]}")"
    )" > /dev/null && pwd
)"

macos_dotfiles="${HOME}/.macos-dotfiles"

# set macos-dotfiles path
if [[ "${dotfiles}" == "${HOME}/.dotfiles" ]]; then
    macos_dotfiles="${dotfiles}"
else
    dotfiles="${HOME}/.dotfiles"
    macos_dotfiles="${HOME}/.macos-dotfiles"
fi

# TIME ~60ms
# append extra paths from files to $PATH, $LIBRARY_PATH, etc.
if [[ -d "${dotfiles}"/extra_paths ]]; then
    source "${macos_dotfiles}/etc/append_to_paths.sh" "${dotfiles}/extra_paths"
fi

## prepare dynamic libraries path
#if [[ "$OS" == "linux" ]]; then
#   export LD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}"
#fi

# use new bash
export SHELL="$(which bash)"

# set cmake makefile generator, compiler, and standard
export CC="$(command -v gcc-11 || command -v clang)"
export CXX="$(command -v g++-11 || command -v clang++)"
export CXX_STD="c++17"
export CMAKE_PREFIX_PATH="${HOMEBREW_PREFIX}/opt/llvm"
export CMAKE_GENERATOR="$( \
    command -v ninja &> /dev/null \
        && echo "Ninja" \
        || echo "" \
)"
export CMAKE_EXPORT_COMPILE_COMMANDS=1

unset dotfiles
unset macos_dotfiles

if [[ $- == *i* ]]; then
    # source bashrc
    if [[ -f ~/.bashrc ]]; then
        source ~/.bashrc
    fi
fi

# export env_after="$(env)"
# diff <(echo "$env_before") <(echo "$env_after") | grep [A-Z_1-9]+\=
# diff <(echo "$env_before") <(echo "$ensudo bash -c "$(declare -f); exec suv_after") | grep [a-z_]+\=
# time bash -i -c 'exit'