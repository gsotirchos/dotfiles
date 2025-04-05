# shellcheck disable=SC1090

# DEPRECATED
# Use with:
#   if [[ -f "${dotfiles}"/completion_dirs ]]; then
#       source "${macos_dotfiles}"/etc/source_dirs_list.sh "${dotfiles}"/completion_dirs
#   fi

# the main function sources a list of files from file contents
# input argument: the file containing the locations of the files to be sourced
main() {
    local dirs_list
    readarray -t dirs_list < <(envsubst < "$@")

    for completions_dir in "${dirs_list[@]}"; do
        if [[ -e "${completions_dir}" ]]; then  # TIME ~200s
            for completion_file in "${completions_dir}"/*; do
                #echo "${completion_file}"
                source "${completion_file}"
            done
        fi
    done
}

main "$@"
unset main
