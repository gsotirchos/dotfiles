#
# ~/.bash_profile
#

#[[ -r ~/.bashrc ]] && . ~/.bashrc

# use color on 'ls'
export CLICOLOR=1

# custom prompt
export PS1="\[\e[0;90m\]\W\[\e[00m\] "

# use pkgin's bash
export SHELL="/opt/pkg/bin/bash"

# set the locale to English
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

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

# extra paths for older versions (unibody macbook)
if [[ "$( sw_vers -productVersion )" =~ 10.11.* ]]; then
    extra_paths+=(
#        "/usr/local/opt/curl/bin"
    )
fi

# append extra paths
eval $(~/.macos-dotfiles/bin/append_paths "${extra_paths[@]}")

# aliases
export TRASH="${HOME}/.Trash"
if [ -f ~/.bash_aliases ]; then
   source ~/.bash_aliases
fi
