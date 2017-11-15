#!/opt/pkg/bin/bash

#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# add ~/.bin to PATH
export PATH=$PATH:~/.bin

# set the updated bash as shell
export SHELL='/opt/pkg/bin/bash'

# set the locale to English
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
