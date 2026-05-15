#!/usr/bin/env bash

main() {
    local target_dir="$(realpath "$1")"
    local destination_dir="$(realpath "$2")"

    # make soft symlinks of files
    for filename in "${target_dir}"/*; do
        if [[ -f "${filename}" ]]; then
            local destination_filepath="${destination_dir}/.$(basename "${filename}")"
            # backup existing files first
            if [[ -e "${destination_filepath}" ]] && [[ ! -L "${destination_filepath}" ]]; then
                env mkdir -vp "${destination_dir}/symlinks_backup"
                echo -n "backup copy: "
                env cp -vfr "${destination_filepath}" "${destination_dir}/symlinks_backup"
            fi
            env ln -sfv "${filename}" "${destination_filepath}"
        fi
    done
}

main "$@"
