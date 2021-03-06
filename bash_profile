#
# ~/.bash_profile
#

# if not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# check if this is a ssh session
if [ -n "${SSH_CLIENT}" ] || [ -n "${SSH_TTY}" ]; then
  SESSION_TYPE="remote_ssh"
else
  case $(ps -o comm= -p $PPID) in
    sshd|*/sshd) SESSION_TYPE="remote_ssh";;
  esac
fi

# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# custom prompt
if [ -f ~/.bash_prompt ]; then
   source ~/.bash_prompt
fi

# use homebrew bash
export SHELL="/opt/homebrew/bin/bash"

# set the locale to English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# iMac's local ip
export imac="192.168.1.2"

# gtest environment
export CPLUS_INCLUDE_PATH="/usr/local/include"
export LIBRARY_PATH="/usr/local/lib"

# homebrew path
eval "$(/opt/homebrew/bin/brew shellenv)"

# extra paths
extra_paths=(
#    "/opt/pkg/gnu/bin"
#    "/opt/pkg/sbin"
#    "/opt/pkg/bin"
#    "/opt/pkg/gcc10/bin"
    "/opt/homebrew/opt/coreutils/libexec/gnubin"
    "$HOME/.bin"
    "$HOME/.dotfiles/bin"
    "$HOME/.local/bin"
    "$HOME/.cabal/bin"                               # haskell
    "${GHCUP_INSTALL_BASE_PREFIX:=$HOME}/.ghcup/bin" # haskell
    "/usr/local/texlive/2019/bin/x86_64-darwin"       # MacTex
    "/usr/local/texlive/2019/bin/x86_64-darwinlegacy" # MacTex
)

# append extra paths
eval $(~/.dotfiles/bin/append_paths "${extra_paths[@]}")

# aliases
export TRASH="${HOME}/.Trash"
if [ -f ~/.bash_aliases ]; then
   source ~/.bash_aliases
fi
