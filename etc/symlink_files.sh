target_dir="$(realpath "$1")"
destination_dir="$(realpath "$2")"

# make soft symlinks of files
for filename in "${target_dir}"/*; do
    if [[ -f "${filename}" ]]; then
        destination_filepath="${destination_dir}/.$(basename "${filename}")"
        # backup existing files first
        if [[ -e "${destination_filepath}" ]] && [[ ! -L "${destination_filepath}" ]]; then
            env mkdir -vp "${destination_dir}/backup"
            echo -n "backup copy: "
            env cp -vfr "${destination_filepath}" "${destination_dir}/backup"
        fi
        env ln -sfv "${filename}" "${destination_filepath}"
    fi
done
