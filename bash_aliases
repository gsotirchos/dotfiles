#
# ~/.bash_aliases
#

# shellcheck shell=bash disable=SC1090,SC2139,SC1091

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

play_trash_sound() {
    if [[ "$OS" == "macos" ]]; then
        touch "${TRASH}"/.delete_me && osascript -e 'tell app "Finder" to empty' \;
    fi
}

empty_trash() {
    if [[ "${TRASH}" == "" ]]; then
        echo "No trash folder found."
        return 1
    elif [[ -n "$(env find "${TRASH}" -maxdepth 0 -type d -empty)" ]]; then
        echo "Trash is already empty."
        return 1
    fi

    read -p "Are you sure you want to permamently erase the items in the trash? [y/N] " -r
    if [[ ${REPLY} =~ ^[Yy]$ ]]; then
        for file in "${TRASH}"/{..?,.[!.],}*; do
            if [[ -e "${file}" ]] || [[ -L "${file}" ]]; then
                env rm -rf --preserve-root "${file}" && echo "deleted '${file}'"
            fi
        done && (play_trash_sound &) 2> /dev/null
    fi
}

touch_url_file() {
    local filename="${1:-file}"
    echo -e "[InternetShortcut]\nURL=$2" > "${filename%.url}.url"
}

benchmark_prompt() {
    time (
        [[ -n "$PROMPT_COMMAND" ]] && eval "$PROMPT_COMMAND"
        _prompt="${PS1@P}"
    )
}

alias rm=trash     # trash files instead of deleting
alias mv="mv -iv"  # confirmatory, verbose
alias cp="cp -ivr" # confirmatory, verbose, recursive
alias ln="ln -iv"  # confirmatory, verbose
alias ls="ls -vh --color=always \
    --group-directories-first"    # human-readable, version-ordered, colored, dirs first
alias ll="ls -l"                  # ll := list
alias la="ls -la"                 # la := list all
alias mkdir="mkdir -pv"           # recursive, verbose
alias chmod="chmod -v"            # verbose
alias chown="chown -v"            # verbose
alias ec="emacsclient -a '' -c &" # start emacs daemon and/or client
alias tree="tree \
    -lFNC -L 2 \
    --dirsfirst \
    -I '.DS_Store|.localized|._*' --matchdirs"
alias ports="lsof -i -P -n | env grep LISTEN" # see what is listening on which ports
alias sftp='$(which with-readline 2> /dev/null) sftp'
alias vimrc="vim ~/.vim/vimrc"
alias wi="vim +WikiIndex"
alias dunnet="clear && emacs -batch -l dunnet 1> /dev/null"
alias py="python3"
alias ipy="ipython"
alias pyclean="find . -type f -name '*.py[co]' -delete -o -type d -name __pycache__ -delete"

if command -v "rg" &> /dev/null; then
    alias grep='rg -p -g "!.git" -g "!.venv" -g "!.conda" -g "!.pixi" -g "!pack"'
else
    alias grep2='env grep --color -I -H -E -n -r --exclude-dir={.git,.venv,.conda,.pixi,pack}'
fi

if command -v "fd" &> /dev/null; then
    alias find='fd -E .git -E .venv -E .conda -E .pixi -E pack'
else
    find() {
        local p=() x=(\( -name .git -o -name .venv -o -name .conda -o -name .pixi -o -name pack \) -prune -o)
        while [[ $1 && ! $1 =~ ^[-!\(] ]]; do
            p+=("$1")
            shift
        done
        if [[ $# -eq 0 ]]; then
            set -- -print
        elif [[ $* =~ -(print|exec|ok|delete|ls) ]]; then
            set -- \( "$@" \)
        else
            set -- \( "$@" \) -print
        fi
        command find "${p[@]:-.}" "${x[@]}" "$@"
    }
fi

if command -v "vint" &> /dev/null; then
    lint-vim() {
        if [[ -f "$1" ]]; then
            vint "$1"
        else
            find "${1:-"."}" -path '*/pack' -prune -o -regex "\(.*\.vim\|.*vimrc\)" -print0 | xargs -0 -n 1 vint
        fi
    }
fi

if ! command -v "open" &> /dev/null; then
    alias open=xdg-open
fi

if [[ "$OS" == "macos" ]]; then
    alias update="brew update && brew upgrade && brew autoremove && brew cleanup --prune=all"
# else
#     ...
fi

if command -v "opencode" &> /dev/null; then
    alias opencode="op-env opencode"
    alias oc="opencode"
fi

if ! command -v "tlmgr" &> /dev/null; then
    alias tlmgr="tlmgr --usermode"
fi

# lazy Conda
if [[ -f ~/.conda/conda_init.sh ]]; then
    # lazy conda initialization
    conda() {
        # TIME ~499ms
        echo -ne "-- Initializing conda ..."
        unset conda
        # export CONDA_BASH_COMPLETION_LOADED="Y"
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

# Catkin (ROS 1)
if command -v "catkin" &> /dev/null; then
    cdws() {
        if catkin locate --workspace "$(realpath "$1")" &> /dev/null; then
            cd "$1" && source "$(catkin locate --devel)"/setup.bash
        else
            echo "Not a Catkin workspace: $(realpath --quiet "$1")"
            return 1
        fi
    }

    # merge all build/*/copmile_commands.json to a single build/copmile_commands.json
    merge_compile_commands() {
        local build_dir="$(catkin locate --build)"
        jq -s 'map(.[])' "${build_dir}"/*/compile_commands.json > "${build_dir}"/compile_commands.json
    }
fi

# Colcon (ROS 2)
if command -v "colcon" &> /dev/null; then
    alias cb="colcon build --symlink-install"
    alias cbp="colcon build --symlink-install --packages-select"
    alias ss="source install/setup.bash"
fi

# Control BLE light bulb
if command -v "ble_write" &> /dev/null; then
    alias ble_lamp='ble_write -n "MIPOW SMART BULB" -u "0000fffc-0000-1000-8000-00805f9b34fb" -v'
fi
