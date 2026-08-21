#!/usr/bin/env bash
# shellcheck disable=SC2155,SC1091
set -euo pipefail

main() {
    local dotfiles="$(
        builtin cd "$(
            realpath "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/.."
        )" > /dev/null && pwd
    )"
    local bright='\033[1m'
    local reset='\033[0m'

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
        stow \
        curl \
        wget \
        software-properties-common

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
        dconf-editor \
        chrome-gnome-shell

    # --- backlight permissions (for light utility) ----------------------
    header "Configuring backlight permissions"
    sudo usermod -aG video "${USER}"
    sudo udevadm trigger --action=add --subsystem-match=backlight
    echo "  Note: log out and back in for the video group to take effect."

    # --- LG UltraFine brightness access (hidraw, no sudo) ---------------
    header "Configuring LG UltraFine brightness access"
    local rules_src
    rules_src="${dotfiles}/etc/udev/90-lg-ultrafine.rules"
    sudo cp "${rules_src}" /etc/udev/rules.d/
    sudo udevadm control --reload
    sudo udevadm trigger --subsystem-match=hidraw
    echo "  Note: replug the LG display (or re-login) for access to take effect."

    # --- keyd (for remapping modifiers) ---------------------------------
    if command -v keyd &> /dev/null; then
        header "keyd already installed — skipping Copilot key remap."
    elif prompt_yn "Remap the Copilot key to a plain Super key (installs keyd)?"; then
        header "Remapping Copilot key → Super (via keyd)"
        # keyd is only in the archive from Ubuntu 25.04 on; use the PPA for 24.04.
        sudo add-apt-repository -y ppa:keyd-team/ppa
        sudo apt update
        sudo apt install -y keyd
        sudo systemctl enable --now keyd
    fi

    # --- macOS-style Super shortcuts (via xremap, app-aware) ------------
    # Layers on top of keyd: keyd swaps Alt/Meta at the evdev level, xremap
    # then rewrites Super+C etc. to Ctrl+C in GTK apps while leaving Emacs
    # and the terminal untouched (see packages/xremap/.config/xremap).
    if ! command -v xremap &> /dev/null \
        && prompt_yn "Install xremap for macOS-style Super shortcuts?"; then
        header "Installing xremap"
        local xr_zip="xremap-linux-x86_64-gnome.zip"
        curl -L -O \
            "https://github.com/xremap/xremap/releases/latest/download/${xr_zip}"
        sudo unzip -o "${xr_zip}" -d /usr/local/bin/
        sudo chmod +x /usr/local/bin/xremap
        rm -f "${xr_zip}"
    fi

    # Grant input access whenever xremap is present — decoupled from the
    # install prompt above so a pre-existing binary still gets set up. All
    # steps are idempotent, so this is safe to re-run.
    if command -v xremap &> /dev/null; then
        # Run xremap as the user (not root): needs read on /dev/input and
        # write on /dev/uinput.
        header "Configuring xremap input access"
        sudo usermod -aG input "${USER}"
        echo uinput | sudo tee /etc/modules-load.d/uinput.conf > /dev/null
        sudo modprobe uinput
        sudo cp "${dotfiles}/etc/udev/99-uinput.rules" /etc/udev/rules.d/
        sudo udevadm control --reload
        sudo udevadm trigger
        # Apply group/mode to the current /dev/uinput node immediately;
        # udev's static_node option only re-applies on module (re)load.
        sudo chgrp input /dev/uinput && sudo chmod 660 /dev/uinput

        echo "  Next steps:"
        echo "    1. Install the GNOME extension 'Xremap' from"
        echo "       https://extensions.gnome.org/extension/5060/xremap/"
        echo "       (required for per-application rules on Wayland)."
        echo "    2. Log out and back in for the 'input' group to take effect."
        echo "    3. Run setup_dotfiles.sh to stow the config and start the service."
    fi

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

    # --- llvm/clang 18 --------------------------------------------------
    if command -v clangd &> /dev/null; then
        header "Clangd already in PATH — skipping."
    elif prompt_yn "Install LLVM/Clang 18?"; then
        header "Installing LLVM/Clang 18"
        local clang_ver="18"
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
    sudo apt install -y shellcheck
    if command -v snap &> /dev/null; then
        sudo snap install shfmt
        sudo snap install universal-ctags --classic
        sudo snap install bash-language-server --classic
    else
        echo "  snap not found — falling back for universal-ctags."
        sudo apt install -y universal-ctags
    fi
    pipx install vim-vint

    # --- python linters / tools -----------------------------------------
    if prompt_yn "Install Python linters and tools (ruff, pylint, lsp, proselint, vint…)?"; then
        header "Installing Python linters and tools"
        for pkg in python-lsp-server pylint ruff proselint mypy cmakelang; do
            pipx install "${pkg}"
        done
        pipx inject python-lsp-server python-lsp-ruff autopep8 isort
        pipx inject cmakelang pyyaml
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
        sudo snap install emacs --channel=pgtk/stable --classic
    fi

    # --- 1password (desktop app + cli) ---------------------------------
    if command -v op &> /dev/null && command -v 1password &> /dev/null; then
        header "1Password already installed — skipping."
    elif prompt_yn "Install 1Password (desktop app + CLI)?"; then
        header "Installing 1Password (desktop app + CLI)"
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
        sudo apt install -y 1password 1password-cli
    fi

    # --- starship prompt -----------------------------------------------
    if command -v starship &> /dev/null; then
        header "Starship already installed — skipping."
    elif prompt_yn "Install Starship prompt?"; then
        header "Installing Starship"
        curl -sS https://starship.rs/install.sh | sh -s -- --yes
    fi

    # --- deskflow (share keyboard/mouse over LAN, Wayland-capable) ------
    if command -v flatpak &> /dev/null \
        && flatpak info org.deskflow.deskflow &> /dev/null; then
        header "Deskflow already installed — skipping."
    elif prompt_yn "Install Deskflow (share keyboard/mouse over LAN)?"; then
        header "Installing Deskflow (via Flatpak)"
        sudo apt install -y flatpak
        flatpak remote-add --user --if-not-exists flathub \
            https://flathub.org/repo/flathub.flatpakrepo
        flatpak install -y --user flathub org.deskflow.deskflow
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
