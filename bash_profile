#
# ~/.bash_profile
#

#[[ -r ~/.bashrc ]] && . ~/.bashrc

# use color on 'ls'
export CLICOLOR=1

# custom prompt
export PS1="\[\e[0;90m\]\W\[\e[00m\] "

# add to PATH
PKG_BIN="/opt/pkg/bin"
PKG_SBIN="/opt/pkg/sbin"
X11_BIN="/opt/X11/bin"
CARGO_BIN="~/.cargo/bin"
export PATH="$PATH:~/.bin"
export PATH="$X11_BIN:${PATH//":$X11_BIN"}"
export PATH="$PKG_SBIN:${PATH//":$PKG_SBIN"}"
export PATH="$PKG_BIN:${PATH//":$PKG_BIN"}"
export PATH="$CARGO_BIN:${PATH//":$CARGO_BIN"}"

# use pkgin's bash
export SHELL="/opt/pkg/bin/bash"

# set the locale to English
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# functions
trash() { # move file(s) to trash folder
    for arg in "$@"; do
        mv -v "$arg" ~/.Trash
    done
}

# aliases
alias rm="trash"  # trash file instead of deleting
#alias rm="rm -i"  # confirmatory remove
alias mv="mv -iv" # confirmatory, verbose move
alias cp="cp -iv" # confirmatory, verbose copy
alias ln="ln -iv" # confirmatory, verbose symlink creaton
alias tree="tree -NC -L 2 --filelimit 15" # cleaner tree
alias dunnet="clear && emacs -batch -l dunnet"
alias julia="clear && 
    /Applications/Julia-1.1.app/Contents/Resources/julia/bin/julia"
