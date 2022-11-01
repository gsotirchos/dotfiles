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

# System
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

# Python
if command -v "python" &> /dev/null; then
    alias python="python3"
    alias py="python3"
    alias pip_upgrade="\
        pip list --outdated --format=freeze | grep -v '^-e' | cut -d = -f 1 \
        | xargs -n1 --no-run-if-empty pip3 install --upgrade \
        && pip cache purge"
fi

# Conda
if command -v "conda" &> /dev/null; then
    if command -v "mamba" &> /dev/null; then
        conda_mamba="mamba"
    else
        conda_mamba="conda"
    fi
    alias env_update="\
    ${conda_mamba} update --all \
    && ${conda_mamba} clean --all -y; \
    ${conda_mamba} list | grep 'pypi' | cut -d ' ' -f 1 \
    | xargs --no-run-if-empty pip install --upgrade \
    && pip cache purge"
    alias env_dump="${conda_mamba} env export | grep -v '^prefix: ' >"
    alias ml="${conda_mamba} activate machine-learning"
    alias mlr_update="\
    ${conda_mamba} env update -n mlr \
    --file '${HOME}/Desktop/RO47002 MLR/environment.yml' --prune \
    && conda clean --all -y"
    unset conda_mamba
fi

# ROS
if command -v "catkin_make" &> /dev/null; then
    alias ccatkin_make="catkin_make --cmake-args -DCMAKE_EXPORT_COMPILE_COMMANDS=1"
    if [[ -n "${catkin_ws}" ]]; then
        alias cdws='cd ${catkin_ws} && . devel/setup.bash'
    fi
fi

# Misc.
if [[ "$(uname -a)" == Darwin* ]]; then
    #
    if [[ -d "${HOME}/Applications/PlayOnMac/Guild Wars 2.app" ]]; then
        alias guildwars2='${HOME}/Applications/PlayOnMac/Guild\ Wars\ 2.app/Contents/MacOS/playonmac'
    fi
    if [[ -d "/Applications/PlayOnMac.app" ]]; then
        alias playonmac='/Applications/PlayOnMac.app/Contents/MacOS/playonmac'
    fi
fi
