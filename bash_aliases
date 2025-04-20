# shellcheck disable=SC1090,SC2139

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
    if [[ -n "$(find "${TRASH}" -maxdepth 0 -type d -empty)" ]]; then
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

# run barrier client daemon with specified server IP
barrier_client() {
    /usr/bin/barrierc \
        -1 \
        --debug INFO \
        --name TUD1001405 \
        --enable-crypto \
        --log /var/log/barrier.log \
        "$1":24800
}

# System
alias rm=trash                  # trash files instead of deleting
alias mv="mv -iv"               # confirmatory, verbose move
alias cp="cp -ivr"              # confirmatory, verbose, recursive
alias ln="ln -iv"               # confirmatory, verbose
alias ls="ls -h --color=always" # human-readable, colored
alias ll="ls -l"                # ll = list ls
alias la="ls -la"               # la = list all ls
alias grep="grep --color -E -n" # colored, extended regexp, line no.
alias tree="\
    tree -lNC -L 2 \
    --dirsfirst \
    -I '.DS_Store|.localized|._*' --matchdirs" # cleaner tree
alias sftp='$(which with-readline 2> /dev/null) sftp'
alias pkg_list="pkg_info -u | sed 's/\(.*\)-[0-9].*/\1/g'"
#alias htop="sudo htop"
alias vimrc="vim ~/.vim/vimrc"
alias e="vim"
alias wi="vim +WikiIndex"
alias dunnet="clear && emacs -batch -l dunnet 2> /dev/null"
if ! command -v "open" &> /dev/null; then
    alias open=xdg-open
fi
alias py="python3"
alias ipy="ipython"
# alias ros_container="ssh -t ubuntu-vm 'singularity exec --bind \$HOME --home \$HOME --writable ros-container/ bash -l'"
# alias ros_container_sudo="ssh -t ubuntu-vm 'sudo singularity shell --writable ros-container/'"
alias ros_container="ssh -t qblox-laptop 'singularity exec --bind \$HOME --home \$HOME --writable ~/Workspaces/benchmarking_ws/benchmarking_container/ bash -l'"
alias ros_container_sudo="ssh -t qblox-laptop 'sudo singularity shell --writable ~/Workspaces/benchmarking_ws/benchmarking_container/'"

# Conda
if [[ -f ~/.conda/conda_init.sh ]]; then
    # lazy conda initialization
    conda() {
        # TIME ~500ms
        echo -ne "${White}Initializing conda ... ${Reset}"
        source ~/.conda/conda_init.sh
        echo -e "${White} done.${Reset}"
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
            cd "$1" \
                && source "$(catkin locate --devel)"/setup.bash
        else
            echo "Not a Catkin workspace: $(realpath --quiet "$1")"
            return 1
        fi
    }
fi

if [[ "$(hostname)" == "ubuntu-vm" ]]; then
    dav_mount() {
        local dav_dir="${HOME}/Public/shared"

        if mountpoint "${dav_dir}" &> /dev/null; then
            echo "Shared directory is already mounted."
            return 1
        fi

        mkdir -p ~/Public/shared
        sudo mount.davfs http://127.0.0.1:9843 ~/Public/shared -o rw,uid="${USER}",gid="${USER}"
    }
fi
