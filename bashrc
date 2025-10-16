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
    local dotfiles="$( \
        builtin cd "$( \
            dirname "$(realpath "${BASH_SOURCE[0]}")"
        )" > /dev/null && pwd
    )"

    local macos_dotfiles="${HOME}/.macos-dotfiles"

    # set macos-dotfiles path
    if [[ "${dotfiles}" == "${HOME}/.dotfiles" ]]; then
        macos_dotfiles="${dotfiles}"
    else
        dotfiles="${HOME}/.dotfiles"
        macos_dotfiles="${HOME}/.macos-dotfiles"
    fi

    # TIME ~60ms
    # append extra paths from files to $PATH, $LIBRARY_PATH, etc.
    if [[ -d "${dotfiles}"/extra_paths ]]; then
        source "${macos_dotfiles}/etc/append_to_paths.sh" "${dotfiles}/extra_paths"
    fi

    ## prepare dynamic libraries path
    #if [[ "${os}" == "linux" ]]; then
    #   export LD_LIBRARY_PATH="${DYLD_LIBRARY_PATH}"
    #fi

    # set the locale to English
    export LC_ALL="en_US.UTF-8"
    export LANG="en_US.UTF-8"

    # use new bash
    export SHELL="$(which bash)"

    # set cmake makefile generator, compiler, and standard
    export CC="$(command -v gcc-11 || command -v clang)"
    export CXX="$(command -v g++-11 || command -v clang++)"
    export CXX_STD="c++17"
    export CMAKE_GENERATOR="$( \
        command -v ninja &> /dev/null \
            && echo "Ninja" \
            || echo "" \
    )"
    export CMAKE_EXPORT_COMPILE_COMMANDS=1

    # append to the history file, don't overwrite it
    shopt -s histappend

    # don't put duplicate lines or lines starting with space in the history.
    export HISTCONTROL=ignoreboth

    # for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
    export HISTSIZE=1000
    export HISTFILESIZE=2000

    # instantly append to history every command
    if ! [[ "${PROMPT_COMMAND}" == *"history -a"* ]]; then
        export PROMPT_COMMAND+=$'\n''history -a'
    fi

    # ignore certain filenames when auto-completing
    export FIGNORE=".DS_Store:"

    # other shell options
    complete -f -o nospace cd  # improve cd completion
    shopt -s direxpand  # expand variables in path completion
    [[ $- == *i* ]] && stty -ixon  # enable Ctrl+S for forward search

    # check if this is a ssh session
    if [[ -n "${SSH_CLIENT}" ]] || [[ -n "${SSH_TTY}" ]]; then
        export IS_SSH_SESSION=true
    else
        case $(ps -o comm= -p "${PPID}") in
            sshd | */sshd) export IS_SSH_SESSION=true ;;
        esac
    fi

    # enable display on ssh connections
    if [[ "${os}" == "linux" ]]; then
        if [[ "${IS_SSH_SESSION}" = true ]]; then
            if [[ "$(hostname)" == "ubuntu-ros-1" ]]; then
                export DISPLAY=":20.0"
            else
                export DISPLAY=":0"
            fi
        fi

        #if [[ ${wsl} = true ]]; then
        #    export DISPLAY="${imac}:0.0"
        #    #export LIBGL_ALWAYS_INDIRECT=0
        #fi

        xhost + local: &> /dev/null
    fi

    # enable local connections (for docker containers)
    # TODO: defaults write org.xquartz.X11 enable_iglx -bool true
    #       defaults write org.xquartz.X11 no_auth -bool true
    #export IP="$(ipconfig getifaddr en0)"
    #export DISPLAY="${IP}:0"
    #xhost + "${IP}" &> /dev/null

    # TIME ~170ms
    # bash completion
    if [[ -f "${HOMEBREW_PREFIX}"/etc/profile.d/bash_completion.sh ]]; then
        source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    fi

    # set __git_ps1 function
    if [[ -f "${macos_dotfiles}"/etc/set_git_ps1.sh ]]; then
        source "${macos_dotfiles}/etc/set_git_ps1.sh"
    fi

    # aliases
    if [[ -f ~/.bash_aliases ]]; then
        source ~/.bash_aliases
    fi

    # custom prompt
    # if [[ -f ~/.bash_prompt ]]; then
    #     source ~/.bash_prompt
    # fi

    # fix polluted subshell's environment from parent shell's conda env
    #if [[ -n "${CONDA_PREFIX}" ]]; then
    #    env="$(basename "${CONDA_PREFIX}")"
    #    unset conda
    #    conda deactivate
    #    conda activate "${env}"
    #fi

    # ROS
    if [[ -f /opt/ros/noetic/setup.bash ]]; then
        # source system's ROS environment
        source "/opt/ros/noetic/setup.bash"
    fi

    # enable iTerm2 shell integration on macOS
    if [[ "$TERM_PROGRAM" = "iTerm.app" ]]; then
        if [[ ! -f ~/.iterm2_shell_integration.bash ]]; then
            curl -L "https://iterm2.com/shell_integration/bash" \
                -o ~/.iterm2_shell_integration.bash
        fi

        # clean up PROMPT_COMMAND to avoid surprises...
        export PROMPT_COMMAND="${PROMPT_COMMAND//__bp_precmd_invoke_cmd$'\n'/}"
        export PROMPT_COMMAND="${PROMPT_COMMAND//$'\n'__bp_interactive_mode/}"
        export PROMPT_COMMAND="${PROMPT_COMMAND//$'\n'__iterm2_prompt_command/}"

        source ~/.iterm2_shell_integration.bash
    fi
}

# export env_before="$(env)"
main "$@"
unset main
# export env_after="$(env)"
# diff <(echo "$env_before") <(echo "$env_after") | grep [A-Z_1-9]+\=
# diff <(echo "$env_before") <(echo "$ensudo bash -c "$(declare -f); exec suv_after") | grep [a-z_]+\=
# time bash -i -c 'exit'
