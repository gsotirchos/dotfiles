#!/usr/bin/env bash

dirs_list="$1"

main () {
    for completions_dir in $@; do
        for completion_file in "${completions_dir}"/*; do
            #echo "${completion_file}"
            source "${completion_file}"
        done
    done
}

main "$(envsubst < "${dirs_list}")"
