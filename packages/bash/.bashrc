#
# ~/.bashrc
#

# shellcheck shell=bash disable=SC1090,SC1091,SC2139

# echo "SOURCED ~/.bashrc"
# [[ $- == *i* ]] && echo 'Interactive' || echo 'Not interactive'
# shopt -q login_shell && echo 'Login shell' || echo 'Not login shell'

# instantly append to history every command
if ! [[ "${PROMPT_COMMAND}" == *"history -a"* ]]; then
    export PROMPT_COMMAND+=$'\n''history -a'
fi

# populate LS_COLORS
if command -v "dircolors" &> /dev/null; then
    eval "$(dircolors -b)"
fi

# ignore certain filenames when auto-completing
export FIGNORE=".DS_Store:"

# set shell options
shopt -s histappend
shopt -s checkwinsize
shopt -s direxpand
shopt -s extglob
shopt -s hostcomplete
complete -f -o nospace cd # improve cd completion
stty -ixon                # enable Ctrl+S for forward search

declare -a files_to_source=(
    "${HOMEBREW_PREFIX}"/etc/profile.d/bash_completion.sh # TIME ~170ms
    /opt/ros/jazzy/setup.bash
    ~/.bash_aliases
)

for file in "${files_to_source[@]}"; do
    if [[ -f "$file" ]]; then
        source "$file"
    fi
done

# pixi
if command -v "pixi" &> /dev/null; then
    eval "$(pixi completion --shell bash)"
fi

# npm
if [[ -d "${HOME}/.nvm" ]]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# enable shell integration
if [[ -n "$GHOSTTY_RESOURCES_DIR" ]]; then
    # enable Ghostty shell integration
    source "${GHOSTTY_RESOURCES_DIR}/shell-integration/bash/ghostty.bash"
fi

export CLAUDE_CODE_NO_FLICKER=1
export BASHRC_SOURCED=1

# configure or start prompt
export PS2="\[\e]133;P;k=s\a\]… \[\e]133;B\a\]"
if command -v "prmt" &> /dev/null && prmt --version &> /dev/null; then
    export PS1='$(prmt --code $? "{path:cyan.bold} {git:magenta.bold}\n{ok:bold:>}{fail:red.bold:>} ")'
    export PS1='${CONDA_DEFAULT_ENV:+\[\e[0;32m\]($CONDA_DEFAULT_ENV)\[\e[0m\] }'"$PS1"
elif command -v "starship" &> /dev/null; then
    export STARSHIP_CONFIG=${HOME}/.config/starship.toml
    eval "$(starship init bash)"
fi
