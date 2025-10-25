target_dir="$(realpath "$1")"
destination_dir="$2"

# make soft symlinks of files
for filename in "${target_dir}"/*; do
    if [[ -f "${filename}" ]]; then
        destination_filepath="${destination_dir}/$(basename "${filename}")"
        # backup existing files first
        if [[ -e "${destination_filepath}" ]] && [[ ! -L "${destination_filepath}" ]]; then
            mkdir -p "${destination_dir}/backup"
            cp -rf "${destination_filepath}" "${destination_dir}/backup"
        fi
        ln -sfv "${filename}" "${destination_filepath}"
    fi
done
