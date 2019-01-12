#
# ~/.bash_profile
#


#[[ -r ~/.bashrc ]] && . ~/.bashrc

# use color
export CLICOLOR=1

# custom prompt
export PS1="\[\e[0;90m\]\W\[\e[00m\] "

# add ~/.bin to PATH
export PATH=/opt/pkg/bin:$PATH:~/.bin

# set the updated bash as shell
export SHELL='/opt/pkg/bin/bash'

# set the locale to English
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# aliases
alias rm='rm -i'
alias dunnet='clear & emacs -batch -l dunnet'
