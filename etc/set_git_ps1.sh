# make git prompt command available
if ! command -v "__git_ps1" &> /dev/null; then
    git_prompt_path="/etc/bash_completion.d/git-prompt"
    if [[ -f "${HOMEBREW_PREFIX}/${git_prompt_path}.sh" ]]; then
        source "${HOMEBREW_PREFIX}/${git_prompt_path}.sh"
    elif [[ -f "${git_prompt_path}" ]]; then
        source "${git_prompt_path}"
    fi
fi

# export git prompt options
export GIT_PS1_SHOWUPSTREAM=auto
export GIT_PS1_SHOWDIRTYSTATE=true
export GIT_PS1_SHOWSTASHSTATE=true
if [[ "${IN_VIM}" != true ]]; then
    export GIT_PS1_SHOWCOLORHINTS=true
    export GIT_PS1_DESCRIBE_STYLE=contains
    export GIT_PS1_SHOWUNTRACKEDFILES=true
else
    export GIT_PS1_SHOWCOLORHINTS=
    export GIT_PS1_DESCRIBE_STYLE=
    export GIT_PS1_SHOWUNTRACKEDFILES=
fi
