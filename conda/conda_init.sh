#
# ~/.conda/conda_init.sh
#

case "$(uname -s)" in
    Linux*)
        conda_path="/opt/miniforge" # NOTE: custom location
        ;;
    Darwin*)
        conda_path="${HOMEBREW_PREFIX}/Caskroom/miniforge/base"
        ;;
esac

if conda_setup="$("${conda_path}/bin/conda" "shell.bash" "hook" 2> /dev/null)"; then
    eval "${conda_setup}"
else
    if [ -f "${conda_path}/etc/profile.d/conda.sh" ]; then
        source "${conda_path}/etc/profile.d/conda.sh"
    elif [[ -d "${conda_path}/bin" ]]; then
        export PATH="${conda_path}/bin:$PATH"
    fi
fi
unset conda_setup

if [ -f "${conda_path}/etc/profile.d/mamba.sh" ]; then
    source "${conda_path}/etc/profile.d/mamba.sh"
fi
unset conda_path

export MAMBA_NO_BANNER=1
