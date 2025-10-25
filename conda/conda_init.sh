#
# ~/.conda/conda_init.sh
#

# shellcheck disable=SC1091


potential_paths=(
    "$(realpath "$(dirname "${CONDA_EXE}")/..")"
    "/opt/miniforge"
    "${HOMEBREW_PREFIX}/Caskroom/miniforge/base"
)

for path in "${potential_paths[@]}"; do
  if [[ -x "${path}/bin/conda" ]]; then
    conda_path="$path"
    break
  fi
done
unset potential_paths

if conda_setup="$("${conda_path}/bin/conda" "shell.bash" "hook" 2> /dev/null)"; then
    eval "${conda_setup}"
    unset conda_setup
else
    if [ -f "${conda_path}/etc/profile.d/conda.sh" ]; then
        source "${conda_path}/etc/profile.d/conda.sh"
    elif [[ -d "${conda_path}/bin" ]]; then
        export PATH="${conda_path}/bin:$PATH"
    fi
fi

if [ -f "${conda_path}/etc/profile.d/mamba.sh" ]; then
    source "${conda_path}/etc/profile.d/mamba.sh"
fi
unset conda_path

export MAMBA_NO_BANNER=1
