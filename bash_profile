#!/opt/pkg/bin/bash

#
# ~/.bash_profile
#

#[[ -f ~/.bashrc ]] && . ~/.bashrc

# aliases
alias bash='/opt/pkg/bin/bash'
alias vim='/opt/pkg/bin/vim'
alias ls='ls -G'
alias tex_template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/report_template.tex'

# add ~/.bin to PATH
export PATH=$PATH:~/.bin

# set the updated bash as shell
export SHELL='/opt/pkg/bin/bash'

# set the locale to English
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
