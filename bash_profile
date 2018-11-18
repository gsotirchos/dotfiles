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
alias report-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/report.tex'
alias subfile-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/subfile.tex'
alias cheatsheet-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/cheatsheet.tex'
alias appendix-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/appendix.tex'
alias references-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/references.tex'
