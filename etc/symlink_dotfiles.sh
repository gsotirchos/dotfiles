#!/usr/bin/env bash

main() {
    local target_dir="$(realpath "$1")"
    local destination_prefix="$2"

    # make soft symlinks of files
    for filename in "${target_dir}"/*; do
        if [[ -f "${filename}" ]]; then
            ln -sfv "${filename}" "${destination_prefix}$(basename "${filename}")"
        fi
    done
}

main "$@"
unset main
