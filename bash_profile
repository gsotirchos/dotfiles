#
# ~/.bash_profile
#


#[[ -r ~/.bashrc ]] && . ~/.bashrc

# use color
export CLICOLOR=1

# custom prompt
export PS1="\e[0;90m\W\e[0m "

# add ~/.bin to PATH
export PATH=$PATH:~/.bin

# set the updated bash as shell
export SHELL='/opt/pkg/bin/bash'

# set the locale to English
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# aliases
alias rm='rm -i'
alias bash='/opt/pkg/bin/bash'
alias vim='/opt/pkg/bin/vim'
alias report-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/report_main_template.tex'
alias subfile-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/subfile_template.tex'
alias cheatsheet-template='curl https://raw.githubusercontent.com/7555G/Windows-scripts/master/templates/cheatsheet_main_template.tex'
