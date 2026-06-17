#!/usr/bin/env bash
# shellcheck disable=SC2155
set -euo pipefail

main() {
    local bright='\033[1m'
    local reset='\033[0m'

    # dotfiles root (directory containing this script's parent)
    local dotfiles="$(
        builtin cd "$(
            realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
        )" > /dev/null && pwd
    )"

    header() { echo -e "\n${bright}- ${1}${reset}"; }
    prompt_yn() {
        local _ans=""
        echo -en "\n${bright}${1} [y/N]${reset} "
        read -r _ans || true
        [[ "${_ans}" =~ ^[Yy]$ ]]
    }

    # --- validate -------------------------------------------------------
    if ! command -v lsb_release &> /dev/null || [[ "$(lsb_release -si)" != "Ubuntu" ]]; then
        echo -e "${bright}Error: This script is intended for Ubuntu.${reset}" >&2
        exit 1
    fi

    # --- system update --------------------------------------------------
    header "Updating system packages"
    sudo apt update
    sudo apt upgrade -y

    # --- core prerequisites ---------------------------------------------
    header "Installing core prerequisites"
    sudo apt install -y \
        git \
        git-lfs \
        stow \
        curl \
        wget \
        software-properties-common
    git lfs install

    # --- general system packages ----------------------------------------
    header "Installing general system packages"
    sudo apt install -y \
        util-linux-extra \
        ubuntu-restricted-extras \
        build-essential \
        cmake \
        ninja-build \
        gdb \
        doxygen \
        cppcheck \
        htop \
        tree \
        jq \
        ripgrep \
        fd-find \
        lsof \
        aspell \
        libsecret-1-0 \
        libsecret-1-dev \
        wl-clipboard \
        xclip \
        pipx \
        python3-pip \
        python3-bashate \
        light \
        gnome-tweaks \
        dconf-editor

    # --- backlight permissions (for light utility) ----------------------
    header "Configuring backlight permissions"
    sudo usermod -aG video "${USER}"
    sudo udevadm trigger --action=add --subsystem-match=backlight
    newgrp video
    echo "  Note: log out and back in for the video group to take effect."

    # --- miniforge (conda/mamba) ----------------------------------------
    local conda_dir="/opt/miniforge"
    if [[ -d "${conda_dir}" ]]; then
        header "Miniforge already present at ${conda_dir} — skipping."
    elif prompt_yn "Install Miniforge (conda/mamba)?"; then
        header "Installing Miniforge → ${conda_dir}"
        local miniforge_script="Miniforge3-$(uname)-$(uname -m).sh"
        curl -L -O \
            "https://github.com/conda-forge/miniforge/releases/latest/download/${miniforge_script}"
        sudo bash "${miniforge_script}" -b -p "${conda_dir}"
        sudo chown -R "${USER}:${USER}" "${conda_dir}"
        rm "${miniforge_script}"
        export MAMBA_NO_BANNER=1
        export MAMBA_ROOT_PREFIX="${conda_dir}"
        # shellcheck disable=SC1091
        source "${conda_dir}/etc/profile.d/conda.sh"
        source "${conda_dir}/etc/profile.d/mamba.sh"
        mamba update --name base conda -y
        mamba update --name base --all -y
        mamba clean --all -y
    fi

    # --- llvm/clang 17 --------------------------------------------------
    if command -v clangd &> /dev/null; then
        header "Clangd already in PATH — skipping."
    elif prompt_yn "Install LLVM/Clang 17?"; then
        header "Installing LLVM/Clang 17"
        local clang_ver="17"
        local llvm_sh
        llvm_sh="$(mktemp)"
        if curl -fsSL "https://apt.llvm.org/llvm.sh" -o "${llvm_sh}"; then
            chmod +x "${llvm_sh}"
            if ! sudo bash "${llvm_sh}" "${clang_ver}" all; then
                echo "  LLVM APT installer failed (Ubuntu 26.04 may not be listed yet)."
                echo "  Falling back to main Ubuntu repos."
                sudo apt install -y clang clangd clang-format clang-tidy
            fi
        else
            echo "  Could not download llvm.sh — falling back to main repos."
            sudo apt install -y clang clangd clang-format clang-tidy
        fi
        rm -f "${llvm_sh}"
        for tool in clang clangd clang-format clang-tidy; do
            if [[ ! -e "/usr/bin/${tool}" ]] \
                && command -v "${tool}-${clang_ver}" &> /dev/null; then
                echo -n "  Adding symlink: "
                sudo ln -sv "/usr/bin/${tool}-${clang_ver}" "/usr/bin/${tool}"
            fi
        done
    fi

    # --- shell linters / formatters -------------------------------------
    header "Installing shell linters and formatters"
    if command -v snap &> /dev/null; then
        sudo snap install shellcheck
        sudo snap install shfmt
        sudo snap install universal-ctags --classic
        sudo snap install bash-language-server --classic
    else
        echo "  snap not found — falling back for shellcheck and universal-ctags."
        local sc_ver="v0.9.0"
        local sc_arch
        sc_arch="$(dpkg --print-architecture)"
        wget -qO- \
            "https://github.com/koalaman/shellcheck/releases/download/${sc_ver}/shellcheck-${sc_ver}.linux.${sc_arch}.tar.xz" \
            | tar -xJv
        sudo install "shellcheck-${sc_ver}/shellcheck" /usr/local/bin/shellcheck
        rm -rf "shellcheck-${sc_ver}"
        sudo apt install -y universal-ctags
    fi
    pipx install vim-vint

    # --- python linters / tools -----------------------------------------
    if prompt_yn "Install Python linters and tools (ruff, pylint, lsp, proselint, vint…)?"; then
        header "Installing Python linters and tools"
        # python-lsp-server and its ruff plugin must share one environment
        pipx install python-lsp-server
        pipx inject python-lsp-server python-lsp-ruff autopep8 isort
        # standalone tools each get their own environment
        for pkg in cmakelang pylint ruff proselint; do
            pipx install "${pkg}"
        done
    fi

    # --- ghostty terminal -----------------------------------------------
    if command -v ghostty &> /dev/null; then
        header "Ghostty already installed — skipping."
    elif prompt_yn "Install Ghostty terminal?"; then
        header "Installing Ghostty"
        bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"
    fi

    # --- vim (latest with clipboard support) ---------------------------
    header "Installing Vim"
    sudo apt install -y vim-gtk3 \
        || sudo apt install -y vim-gtk \
        || sudo apt install -y vim

    # --- emacs (graphical) ---------------------------------------------
    if command -v emacs &> /dev/null; then
        header "Emacs already installed — skipping."
    elif prompt_yn "Install Emacs (GTK graphical)?"; then
        header "Installing Emacs (GTK graphical)"
        sudo apt install -y emacs-gtk
    fi

    # --- 1password cli -------------------------------------------------
    if command -v op &> /dev/null; then
        header "OP already installed — skipping."
    elif prompt_yn "Install 1Password CLI (op)?"; then
        header "Installing 1Password CLI"
        local arch
        arch="$(dpkg --print-architecture)"
        curl -sS https://downloads.1password.com/linux/keys/1password.asc \
            | sudo gpg --dearmor \
                --output /usr/share/keyrings/1password-archive-keyring.gpg
        echo "deb [arch=${arch} signed-by=/usr/share/keyrings/1password-archive-keyring.gpg] \
https://downloads.1password.com/linux/debian/${arch} stable main" \
            | sudo tee /etc/apt/sources.list.d/1password.list > /dev/null
        sudo mkdir -p /etc/debsig/policies/AC2D62742012EA22/
        curl -sS https://downloads.1password.com/linux/debian/debsig/1password.pol \
            | sudo tee /etc/debsig/policies/AC2D62742012EA22/1password.pol > /dev/null
        sudo mkdir -p /usr/share/debsig/keyrings/AC2D62742012EA22
        curl -sS https://downloads.1password.com/linux/keys/1password.asc \
            | sudo gpg --dearmor \
                --output /usr/share/debsig/keyrings/AC2D62742012EA22/debsig.gpg
        sudo apt update
        sudo apt install -y 1password-cli
    fi

    # --- starship prompt -----------------------------------------------
    if command -v starship &> /dev/null; then
        header "Starship already installed — skipping."
    elif prompt_yn "Install Starship prompt?"; then
        header "Installing Starship"
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi

    # --- claude code ---------------------------------------------------
    if command -v claude &> /dev/null; then
        header "Claude Code already installed — skipping."
    elif prompt_yn "Install Claude Code?"; then
        header "Installing Claude Code"
        curl -fsSL https://claude.ai/install.sh | bash
    fi

    # --- done --------------------------------------------------------------
    echo ""
    echo -e "${bright}Setup complete. Run next:${reset}"
    echo "  bash ~/.dotfiles/etc/setup_dotfiles.sh"
}

main "$@"
unset main
