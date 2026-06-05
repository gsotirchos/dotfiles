# shellcheck disable=SC1090

main() {
    local go_install_path="/usr/local/go"
    local singularity_version="3.11.4"

    # Ensure repositories are up-to-date
    sudo apt update

    # Install debian packages for dependencies
    sudo apt install -y \
         build-essential \
         libseccomp-dev \
         libglib2.0-dev \
         pkg-config \
         squashfs-tools \
         cryptsetup \
         runc

    if [[ -d "${go_install_path}" ]] || (command -v "go" &> /dev/null); then
        echo "-- Go is already installed; skipping its installation..."
    else
        sudo snap install --classic go

        # # Manually download and install Go
        # local os="linux"
        # local arch="arm64"
        # local go_version="1.20.4"
        # local go_user_path="${HOME}/go"
        # wget "https://dl.google.com/go/go${go_version}.${os}-${arch}.tar.gz" && \
            #     sudo tar -C "$(dirname "${go_install_path}")" -xzvf "go${go_version}.${os}-${arch}.tar.gz" && \
            #     rm "go${go_version}.${os}-${arch}.tar.gz"
        #
        # # Set up your environment for Go
        # local old_path="${PATH}"
        # export PATH="${go_install_path}/bin:${old_path}:${go_user_path}/bin"
    fi

    # Download SingularityCE 3.11.4 from a release
    wget "https://github.com/sylabs/singularity/releases/download/v${singularity_version}/singularity-ce-${singularity_version}.tar.gz" && \
        tar -xzf "singularity-ce-${singularity_version}.tar.gz" && \
        cd "singularity-ce-${singularity_version}" || return 1

    # Build and install Singularity
    ./mconfig && \
        make -C ./builddir && \
        sudo make -C ./builddir install

    # Enable bash completion for Singularity
    echo ". /usr/local/etc/bash_completion.d/singularity" >> ~/.bashrc && source ~/.bashrc

    # Check if the installation was sucessful
    if ! (command -v "singularity" &> /dev/null); then
        echo "-- Failed to install singularity!"
        return 1
    fi

    # # Reset environment
    # export PATH="${old_path}"

    # Clean up build files
    cd - || return 1
    rm "singularity-ce-${singularity_version}"

    # Optional: remove Go
    sudo snap remove --purge go
    # sudo rm -rf "${go_user_path}" "${go_install_path}"
}

main "$@"
