#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

# the main function appends paths from file contents to $PATH, $LIBRARY_PATH, etc.
# input argument: the directory containing the files specifying the paths to be appended
main() {
    local extra_paths_dir
    extra_paths_dir="$(realpath "$1")"

    for extra_paths_file in "${extra_paths_dir}"/*; do
        # Only process regular files (the path definition files)
        if [[ -f "$extra_paths_file" ]]; then
            local global_var_name
            global_var_name="$(basename "${extra_paths_file}")"
            global_var_name="${global_var_name%%.*}"

            local extra_paths
            readarray -t extra_paths < <(envsubst < "${extra_paths_file}")  # expand env vars in paths

            # append paths to global variable
            append_paths "$global_var_name" "${extra_paths[@]}"
        fi
    done
}
# append paths to global variable
# input argument 1: the global variable name
# input argument 2...: the paths to be appended
append_paths() {
    local global_var_name="$1"
    shift

    local paths_to_add=($(eval echo \"$@\"))  # expand widlcards
    local -A added_paths  # Use an associative array as a set

    # Populate the set with existing paths (for faster lookup)
    IFS=':' read -ra existing_paths <<< "${!global_var_name}"
    for path in "${existing_paths[@]}"; do
        added_paths["$path"]=1
    done

    local new_path_string="${!global_var_name}"

    for path in "${paths_to_add[@]}"; do
        if [[ "${added_paths["$path"]}" ]]; then
            continue
        fi
        if [[ "${path:0:1}" == "#" ]]; then
            #echo "skipped: $path"
            continue
        fi
        #echo -e "appended to $global_var_name: $path"
        filtered_paths+=("$path")
        new_path_string="$path:$new_path_string"  # TIME: ~200ms !!!
        added_paths["$path"]=1
    done

    export "$global_var_name=$new_path_string"
}

main "$@"
unset main
