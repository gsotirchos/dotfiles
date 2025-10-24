# shellcheck disable=SC1090,SC2139

#
# ~/.bash_aliases
#

if [[ "$OS" == "macos" ]]; then
    export TRASH="${HOME}/.Trash"
else
    export TRASH="${HOME}/.local/share/Trash/files"
fi

# rm wrapper to move file(s) to trash folder instead of deleting them
trash() {
    if [[ "${TRASH}" == "" ]]; then
        echo "No trash folder found."
        return 1
    fi

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
play_trash_sound() {
    if [[ "$OS" == "macos" ]]; then
        touch "${TRASH}"/.delete_me && osascript -e 'tell app "Finder" to empty' \;
    fi
}

# empty the trash folder
empty_trash() {
    if [[ "${TRASH}" == "" ]]; then
        echo "No trash folder found."
        return 1
    elif [[ -n "$(find "${TRASH}" -maxdepth 0 -type d -empty)" ]]; then
        echo "Trash is already empty."
        return 1
    fi

    read -p "Are you sure you want to permamently erase the items in the trash? [y/N] " -r
    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
        for file in "${TRASH}"/{..?,.[!.],}*; do
            if [[ -e "${file}" ]] || [[ -L "${file}" ]]; then
                env rm -rf "${file}" && echo "deleted '${file}'"
            fi
        done && (play_trash_sound &) 2> /dev/null
    fi
}

# make a .url file with given link
make_url() {
    echo -e "[InternetShortcut]\nURL=$2" > "${1%%.url}.url"
}

# merge all build/*/copmile_commands.json to a single build/copmile_commands.json
merge_compile_commands() {
    if command -v "catkin" &> /dev/null; then
        local build_dir="$(catkin locate --build)"
        jq -s 'map(.[])' "${build_dir}"/*/compile_commands.json > "${build_dir}"/compile_commands.json
    fi
}

# System
alias ec="emacsclient -a '' -c &"  # start emacs daemon and/or client
alias rm=trash                     # trash files instead of deleting
alias mv="mv -iv"                  # confirmatory, verbose
alias cp="cp -ivr"                 # confirmatory, verbose, recursive
alias ln="ln -iv"                  # confirmatory, verbose
alias ls="ls -h --color=always"    # human-readable, colored
alias ll="ls -l"                   # ll := list
alias la="ls -la"                  # la := list all
if command -v "rg" &> /dev/null; then
    alias grep="rg -p"
else
    alias grep="grep --color -E -n"  # colored, extended regexp, line no.
fi
alias tree="tree \
    -lNC -L 2 \
    --dirsfirst \
    -I '.DS_Store|.localized|._*' --matchdirs"
alias sftp='$(which with-readline 2> /dev/null) sftp'
alias pkg_list="pkg_info -u | sed 's/\(.*\)-[0-9].*/\1/g'"
alias vimrc="vim ~/.vim/vimrc"
alias wi="vim +WikiIndex"
alias dunnet="clear && emacs -batch -l dunnet 2> /dev/null"
if ! command -v "open" &> /dev/null; then
    alias open=xdg-open
fi
alias py="python3"
alias ipy="ipython"

# lazy Conda
if [[ -f ~/.conda/conda_init.sh ]]; then
    # lazy conda initialization
    conda() {
        # TIME ~499ms
        echo -ne "-- Initializing conda ..."
        unset conda
        source ~/.conda/conda_init.sh
        echo -e " DONE"
        conda "$@"
    }

    if command -v "mamba" &> /dev/null; then
        conda_mamba="mamba"
    else
        conda_mamba="conda"
    fi

    alias env_dump="${conda_mamba} env export | cut -f 1 -d '=' | /usr/bin/env grep -v '^prefix: ' >"
    alias sb="${conda_mamba} activate sandbox &> /dev/null"

    unset conda_mamba
fi

if command -v "ble_write" &> /dev/null; then
    alias ble_lamp='ble_write -n "MIPOW SMART BULB" -u "0000fffc-0000-1000-8000-00805f9b34fb" -v'
fi

# Catkin
if command -v "catkin" &> /dev/null; then
    cdws() {
        if catkin locate --workspace "$(realpath "$1")" &> /dev/null; then
            cd "$1" && source "$(catkin locate --devel)"/setup.bash
        else
            echo "Not a Catkin workspace: $(realpath --quiet "$1")"
            return 1
        fi
    }
fi
