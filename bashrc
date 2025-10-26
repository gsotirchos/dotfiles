#
# ~/.bashrc
#

# shellcheck disable=SC1090,SC1091,SC2139

# echo "SOURCED ~/.bashrc"
# [[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'
# shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'

export EDITOR="vim"

# instantly append to history every command
if ! [[ "${PROMPT_COMMAND}" == *"history -a"* ]]; then
    export PROMPT_COMMAND+=$'\n''history -a'
fi

# ignore certain filenames when auto-completing
export FIGNORE=".DS_Store:"

# set shell options
shopt -s histappend
shopt -s checkwinsize
shopt -s direxpand
shopt -s extglob
shopt -s hostcomplete
complete -f -o nospace cd  # improve cd completion
stty -ixon  # enable Ctrl+S for forward search

# TIME ~170ms
# bash completion
if [[ -f "${HOMEBREW_PREFIX}"/etc/profile.d/bash_completion.sh ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
fi

# aliases
if [[ -f ~/.bash_aliases ]]; then
    source ~/.bash_aliases
fi

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

    # clean up PROMPT_COMMAND just in case, to avoid surprises...
    export PROMPT_COMMAND="${PROMPT_COMMAND//__bp_precmd_invoke_cmd$'\n'/}"
    export PROMPT_COMMAND="${PROMPT_COMMAND//$'\n'__bp_interactive_mode/}"
    export PROMPT_COMMAND="${PROMPT_COMMAND//$'\n'__iterm2_prompt_command/}"

    source ~/.iterm2_shell_integration.bash
fi

# HPC
if [[ "$(hostname)" =~ login[0-9]+ ]]; then
    export TERM="vt100"
    #export TMPDIR="~/.tmp"
    export SCRATCH="/scratch/${USER}"
    export RISC="${SCRATCH}/RISC/risc"
    export SQUEUE_FORMAT="%.10i %.60j %.18a %.17R %M"
    alias rm="rm -I"
    alias live_squeue="while true; do clear; squeue --me -o \"$SQUEUE_FORMAT\"; sleep 1; done"
    alias scancel_all="squeue --noheader --format %i | xargs scancel"
    rlhive() {
        if command -v "module" &> /dev/null; then
            echo -n "Loading module miniconda3... "
            module load miniconda3 && echo "DONE"
        fi
        echo -n "Activating \"rlhive\" conda env... "
        conda activate rlhive && echo "DONE"
    }
    rlhive
fi

# starship prompt
if command -v "starship" &> /dev/null; then
    eval "$(starship init bash)"
fi

