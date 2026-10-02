#
# ~/.conda/conda_init.sh
#

# shellcheck shell=bash disable=SC1091

main() {
    local conda_exe_dir=""
    if [[ -n "${CONDA_EXE:-}" ]]; then
        conda_exe_dir="$(realpath "$(dirname "${CONDA_EXE}")/..")"
    fi

    local potential_paths=(
        "${conda_exe_dir}"
        "/opt/miniforge"
        "${HOMEBREW_PREFIX:-}/Caskroom/miniforge/base"
    )

    local conda_path="" path
    for path in "${potential_paths[@]}"; do
        if [[ -n "${path}" ]] && [[ -x "${path}/bin/conda" ]]; then
            conda_path="$path"
            break
        fi
    done

    if [[ -n "${conda_path}" ]]; then
        local conda_setup
        if conda_setup="$("${conda_path}/bin/conda" "shell.bash" "hook" 2> /dev/null)"; then
            eval "${conda_setup}"
        else
            if [ -f "${conda_path}/etc/profile.d/conda.sh" ]; then
                source "${conda_path}/etc/profile.d/conda.sh"
            elif [[ -d "${conda_path}/bin" ]]; then
                export PATH="${conda_path}/bin:${PATH:-}"
            fi
        fi

        if [ -f "${conda_path}/etc/profile.d/mamba.sh" ]; then
            export MAMBA_ROOT_PREFIX="$conda_path"
            source "${conda_path}/etc/profile.d/mamba.sh"
        fi
    fi

    export MAMBA_NO_BANNER=1
}

main "$@"
unset main
