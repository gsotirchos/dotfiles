#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

#
# ~/.bashrc
#

main() {
    # determine OS
    case "$(uname -s)" in
        Linux*)
            local os="linux"
            if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
                local wsl=true
            else
                local wsl=false
            fi
            ;;
        Darwin*)
            local os="macos"
            ;;
    esac

    # set dotfiles path
    local dotfiles="$(
        builtin cd "$(
            dirname "$(realpath "${BASH_SOURCE[0]}")"
        )" > /dev/null && pwd
    )"

    local macos_dotfiles="${HOME}"/.macos-dotfiles

    # set macos-dotfiles path
    if [[ "${dotfiles}" == "${HOME}"/.dotfiles ]]; then
        macos_dotfiles="${dotfiles}"
    else
        dotfiles="${HOME}"/.dotfiles
        macos_dotfiles="${HOME}"/.macos-dotfiles
    fi

    # append extra paths from files to $PATH, $LIBRARY_PATH, etc.
    if [[ -d "${dotfiles}"/extra_paths ]]; then
        source "${macos_dotfiles}"/etc/append_to_paths.sh "${dotfiles}"/extra_paths
    fi

    ## prepare dynamic libraries path
    #if [[ "${os}" == "linux" ]]; then
    #    export LD_LIBRARY_PATH="${LIBRARY_PATH}"
    #elif [[ "${os}" == "macos" ]]; then
    #    export DYLD_LIBRARY_PATH="${LIBRARY_PATH}"
    #fi

    # set the locale to English
    export LC_ALL="en_US.UTF-8"
    export LANG="en_US.UTF-8"

    # use new bash
    export SHELL="$(which bash)"

    # set cmake makefile generator, compiler, and standard
    export CC="$(which gcc-7 2> /dev/null)"
    export CXX="$(which g++-7 2> /dev/null)"
    #export CC="$(which clang 2> /dev/null)"
    #export CXX="$(which clang++ 2> /dev/null)"
    export CXX_STD="c++17"
    #export CMAKE_GENERATOR="Ninja"
    export CMAKE_EXPORT_COMPILE_COMMANDS=1

    # append to the history file, don't overwrite it
    shopt -s histappend

    # don't put duplicate lines or lines starting with space in the history.
    export HISTCONTROL=ignoreboth

    # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
    export HISTSIZE=1000
    export HISTFILESIZE=2000

    # instantly append to history every command
    export PROMPT_COMMAND="${PROMPT_COMMAND%; }; history -a"
    export PROMPT_COMMAND="${PROMPT_COMMAND#; }"

    # ignore certain filenames when auto-completing
    export FIGNORE=".DS_Store:"

    # other shell options
    complete -f -o nospace cd # improve cd completion
    shopt -s direxpand        # expand variables in path completion

    # local ip shortcuts
    export imac="iMac.local"
    export macbookair="MacBookAir.local"
    export ubuntu_vm="ubuntu-vm.local"

    # check if this is a ssh session
    if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_TTY}" ]]; then
        local session_type="remote_ssh"
    else
        case $(ps -o comm= -p "${PPID}") in
            sshd | */sshd) local session_type="remote_ssh" ;;
        esac
    fi

    # enable display on ssh connections
    if [[ "${os}" == "linux" ]]; then
        if [[ "${session_type}" == "remote_ssh" ]]; then
            export DISPLAY=:0
        fi

        if [[ ${wsl} = true ]]; then
            export DISPLAY="${imac}:0.0"
            #export LIBGL_ALWAYS_INDIRECT=0
        fi

        xhost + local: &> /dev/null
    fi

    # enable local connections (for docker containers)
    # TODO: defaults write org.xquartz.X11 enable_iglx -bool true
    #       defaults write org.xquartz.X11 no_auth -bool true
    #export IP="$(ipconfig getifaddr en0)"
    #export DISPLAY="${IP}:0"
    #xhost + "${IP}" &> /dev/null

    # Conda
    if [[ -f ~/.conda/conda_init ]]; then
        source ~/.conda/conda_init

        if [[ -n "${CONDA_PREFIX}" ]]; then
            conda deactivate
            conda activate "$(basename "${CONDA_PREFIX}")"
        fi
    fi

    # ROS
    if [[ -f /opt/ros/noetic/setup.bash ]]; then
        # source system's ROS environment
        source /opt/ros/noetic/setup.bash
    fi

    # aliases
    if [[ -f ~/.bash_aliases ]]; then
        source ~/.bash_aliases
    fi

    # custom prompt
    if [[ -f ~/.bash_prompt ]]; then
        source ~/.bash_prompt
    fi

    # auto-completion
    if [[ -f "${dotfiles}"/completion_dirs ]]; then
        source "${macos_dotfiles}"/etc/source_dirs_list.sh "${dotfiles}"/completion_dirs
    fi

    # iTerm2 shell integration
    #if [[ "${os}" == "macos" ]]; then
    if [[ ! -f ~/.iterm2_shell_integration.bash ]]; then
        curl -L https://iterm2.com/shell_integration/bash \
            -o ~/.iterm2_shell_integration.bash
    fi

    source ~/.iterm2_shell_integration.bash
    #fi
}

main "$@"
unset main
