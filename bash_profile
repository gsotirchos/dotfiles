#
# ~/.bash_profile
#

# if not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# custom prompt
export PS1="\[\e[0;90m\]\W\[\e[00m\] "

# use color on 'ls'
export CLICOLOR=1

# use pkgin's bash
export SHELL="/opt/pkg/bin/bash"

# set the locale to English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# gtest environment
export CPLUS_INCLUDE_PATH="/usr/local/include"
export LIBRARY_PATH="/usr/local/lib"

# MacBook's local ip
export macbook="192.168.1.2"

# extra paths
extra_paths=(
    "/usr/local/bin" # Homebrew
    "/opt/X11/bin"
    "/opt/pkg/sbin"
    "/opt/pkg/bin"
    "/opt/pkg/gcc10/bin"
    "$HOME/.bin"
    "$HOME/.dotfiles/bin"
    "$HOME/.local/bin"
    "$HOME/.cabal/bin"                               # haskell
    "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/bin" # haskell
    "/usr/local/texlive/2019/bin/x86_64-darwin"       # MacTex
    "/usr/local/texlive/2019/bin/x86_64-darwinlegacy" # MacTex
)

## more extra paths for older versions (unibody macbook)
#if [[ "$( sw_vers -productVersion )" =~ 10.11.* ]]; then
#    extra_paths+=(
#        "/usr/local/opt/curl/bin"
#    )
#fi

# append extra paths
eval $(~/.dotfiles/bin/append_paths "${extra_paths[@]}")

# aliases
export TRASH="${HOME}/.Trash"
if [ -f ~/.bash_aliases ]; then
   source ~/.bash_aliases
fi
