#!/usr/bin/env bash

# function to append argument list, in reverse order, to an environment var
append_paths() {
    # fist argument is the name of the environment variable
    local global_var_name="$1"
    local current_paths="${!global_var_name}"
    shift

    # gather in reverse order the rest of the arguments-paths that exist
    for extra_path in $@; do
        if [[ -d "${extra_path}" ]]; then
            #echo "extra path: ${extra_path}"
            current_paths="${extra_path}:${current_paths}"
            current_paths="${current_paths//:$extra_path}"
        fi
    done

    export "${global_var_name}=${current_paths%:}"
}

main() {
    # input argument is the dir containing text files each named according
    # to the environment var to which its contents are to be appended
    extra_paths_dir="$(realpath $1)"

    for extra_paths_file in "${extra_paths_dir}"/*; do
        #echo "modifying: ${extra_paths_file}"
        global_var_name="$(basename "${extra_paths_file%.*}")"

        append_paths "${global_var_name}" "$(envsubst < "${extra_paths_file}")"
    done
}

main "$@"
