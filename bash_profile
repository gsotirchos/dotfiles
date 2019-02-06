#
# ~/.bash_profile
#

#[[ -r ~/.bashrc ]] && . ~/.bashrc

# use color on 'ls'
export CLICOLOR=1

# custom prompt
export PS1="\[\e[0;90m\]\W\[\e[00m\] "

# add to PATH
export PATH="$PATH:~/.bin"
export PATH="/opt/pkg/bin:$PATH"
export PATH="~/.cargo/bin:$PATH"

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
alias rm="rm -i" # confirmation before removing
alias mv="mv -v" # verbose move
alias tree="tree -NC -L 2 --filelimit 15" # cleaner tree
alias dunnet="clear && emacs -batch -l dunnet"
alias julia="clear && 
    /Applications/Julia-1.1.app/Contents/Resources/julia/bin/julia"
