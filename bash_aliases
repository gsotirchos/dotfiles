#!/usr/bin/env bash

#
# ~/.bash_aliases
#

if [[ "${os}" == "linux" ]]; then
    export TRASH="${HOME}/.local/share/Trash/files"
elif [[ "${os}" == "macos" ]]; then
    export TRASH="${HOME}/.Trash"
fi

# rm wrapper to move file(s) to trash folder instead of deleting them
trash() {
    local flags=()
    for arg in "$@"; do
        if [[ ${arg} == -* ]]; then
            flags=("${flags[@]}" "${arg}")
            continue
        fi

        # move file to trash folder, or delete /tmp/* files
        if [[ ${arg} == "/tmp/"* ]]; then
            #echo "rm -r ${arg%/}"
            env rm -r "${arg%/}"
        else
            #echo "mv ${flags[@]} -v --backup=numbered ${arg%/} ${TRASH}"
            env mv "${flags[@]}" -v --backup=numbered "${arg%/}" "${TRASH}"
        fi
    done
}

# play the "empty trash" sound on macOS
if [[ "${os}" == "macos" ]]; then
    play_trash_sound() {
        touch "${TRASH}"/.delete_me \
            && osascript -e 'tell app "Finder" to empty' \;
    }
fi

# empty the trash folder
empty_trash() {
    if [[ -n "$(find "${TRASH}" -type d -empty)" ]]; then
        echo "Trash is already empty."
        return 1
    fi

    read -p "Are you sure you want to permamently erase the items in the trash? [y/N] " -r
    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
        for file in "${TRASH}"/{..?,.[!.],}*; do
            if [[ -e "${file}" ]] || [[ -L "${file}" ]]; then
                env rm -rf "${file}" \
                    && echo "deleted '${file}'"
            fi
        done && (play_trash_sound &)
    fi
}

# make a .url file with given link
make_url() {
    echo -e "[InternetShortcut]\nURL=$2" > "$1"
}

# merge all build/*/copmile_commands.json to a single build/copmile_commands.json
merge_compile_commands() {
    if command -v "catkin" &> /dev/null; then
        local build_dir="$(catkin locate --build)"
        jq -s 'map(.[])' "${build_dir}"/*/compile_commands.json > "${build_dir}"/compile_commands.json
    fi
}

# System
alias rm=trash                  # trash files instead of deleting
alias mv="mv -iv"               # confirmatory, verbose move
alias cp="cp -ivr"              # confirmatory, verbose, recursive
alias ln="ln -iv"               # confirmatory, verbose
alias ls="ls -h --color=always" # human-readable, colored
alias ll="ls -l"                # list ls := ll
alias grep="grep --color -E -n" # colored, extended regexp, line no.
alias tree="\
    tree -lNC -L 2 \
    --dirsfirst \
    -I '.DS_Store|.localized|._*' --matchdirs" # cleaner tree
alias sftp='$(which with-readline 2> /dev/null) sftp'
alias pkg_list="pkg_info -u | sed 's/\(.*\)-[0-9].*/\1/g'"
alias htop="sudo htop"
alias vimrc="vim ~/.vim/vimrc"
alias dunnet="clear && emacs -batch -l dunnet 2> /dev/null"

# Python
if command -v "python" &> /dev/null; then
    alias python="python3"
    alias py="python3"
fi

# iPython
if command -v "ipython" &> /dev/null; then
    alias ipy="ipython"
fi

# Conda
if command -v "conda" &> /dev/null; then
    if command -v "mamba" &> /dev/null; then
        conda_mamba="mamba"
    else
        conda_mamba="conda"
    fi
    #alias env_update="\
    #    ${conda_mamba} update --all \
    #    && ${conda_mamba} clean --all -y; \
    #    ${conda_mamba} list | grep 'pypi' | cut -d ' ' -f 1 \
    #    | xargs --no-run-if-empty pip install --upgrade \
    #    && pip cache purge"
    alias env_dump="${conda_mamba} env export | grep -v '^prefix: ' >"
    alias ml="${conda_mamba} activate machine-learning"
    unset conda_mamba
fi

# Google Cloud VM
alias google_cloud_vm="ssh -i ~/.ssh/id_ed25519 gsotirch@34.69.201.168" # TODO

# Catkin
if command -v "catkin" &> /dev/null; then
    cdws() {
        if catkin profile --workspace "$1" &> /dev/null; then
            cd "$1" && source "$(catkin locate --devel)"/setup.bash
        else
            echo "Not a Catkin workspace: $(realpath --quiet "$1")"
            return 1
        fi
    }
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
