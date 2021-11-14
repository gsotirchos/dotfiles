#!/usr/bin/env bash

target_dir="$(realpath "$1")"
destination_prefix="$2"

# make soft symlinks of dotfiles
for filename in "${target_dir}"/*; do
    if [[ -f "${filename}" ]]; then
        ln -sfv "${filename}" \
            "${destination_prefix}$(basename "${filename}")"
    fi
done
