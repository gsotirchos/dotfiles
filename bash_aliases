#!/usr/bin/env bash

#
# ~/.bash_aliases
#

if [[ "${os}" == "linux" ]]; then
    export TRASH="${HOME}/.local/share/Trash/files"
elif [[ "${os}" == "macos" ]]; then
    export TRASH="${HOME}/.Trash"
fi

# rm wrapper to move file(s) to trash folder
trash() {
    local flags=""
    for arg in "$@"; do
        if [[ ${arg} == -* ]]; then
            flags="${flags} ${arg}"
            continue
        fi

        # move file to trash folder, or delete /tmp/* files
        if [[ ${arg} == "/tmp/"* ]]; then
            #echo "rm -r ${arg%/}"
            env rm -r "${arg%/}"
        else
            #echo "mv ${flags} -v --backup=numbered ${arg%/} ${TRASH}"
            env mv ${flags} -v --backup=numbered "${arg%/}" "${TRASH}"
        fi
    done
}

# function to empty trash
empty_trash() {
    read -p "Are you sure you want to permamently erase the items in the trash? [y/N] " -r
    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
        for file in "${TRASH}"/{..?,.[!.],}*; do
            if [[ -e "${file}" ]] || [[ -L "${file}" ]]; then
                env rm -rf "${file}" \
                    && echo "deleted '${file}'"
            fi
        done
    fi
}

# aliases
alias rm=trash                  # trash files instead of deleting
alias mv="mv -iv"               # confirmatory, verbose move
alias cp="cp -ivr"              # confirmatory, verbose, recursive
alias ln="ln -iv"               # confirmatory, verbose
alias ls="ls -h --color=always" # human-readable, colored
alias ll="ls -l"                # list ls := ll
alias grep="grep --color -E"    # colored, enable extended regexp
alias tree="\
    tree -lNFC -L 2 \
    --dirsfirst \
    -I '.DS_Store|.localized|._*' --matchdirs" # cleaner tree
alias sftp='$(which with-readline 2> /dev/null) sftp'
alias pkg_list="pkg_info -u | sed 's/\(.*\)-[0-9].*/\1/g'"
alias vimrc="vim ~/.vim/vimrc"
alias dunnet="clear && emacs -batch -l dunnet"

alias python="python3"
alias py="python3"
alias pip="pip3"
alias pip_upgrade='\
    pip list --outdated --format=freeze \
    | grep -v '^\-e' | cut -d = -f 1 | xargs -n1 pip3 install --upgrade'
alias env_update='\
    pip_upgrade; \
    mamba update --all \
    && mamba list | grep "pypi" | cut -d " " -f 1 | xargs pip install --upgrade'
alias mlr="conda activate mlr"
alias ccatkin_make="catkin_make --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
if [[ -n "${catkin_ws}" ]]; then
    alias cdws='cd ${catkin_ws} && . devel/setup.bash'
fi
if [[ -d "${HOME}/Applications/PlayOnMac/Guild Wars 2.app" ]]; then
    alias guildwars2='${HOME}/Applications/PlayOnMac/Guild\ Wars\ 2.app/Contents/MacOS/playonmac'
fi
if [[ -d "/Applications/PlayOnMac.app" ]]; then
    alias playonmac='/Applications/PlayOnMac.app/Contents/MacOS/playonmac'
fi
