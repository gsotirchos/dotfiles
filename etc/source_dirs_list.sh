#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2155

# the main function to source a list of files from file contents
# input argument: the location of the file containing the locations of the sourced files
main () {
    local dirs_list
    readarray -t dirs_list < <(envsubst < "$1")

    for completions_dir in ${dirs_list[@]}; do
        if [[ -e "${completions_dir}" ]]; then
            for completion_file in "${completions_dir}"/*; do
                #echo "${completion_file}"
                source "${completion_file}"
            done
        fi
    done
}

main "$@"
