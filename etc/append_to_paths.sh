#!/usr/bin/env bash

# the main function appends paths from file contents to $PATH, $LIBRARY_PATH, etc.
# input argument: the directory containing the files specifying the paths to be appended
main() {
    # don't run in subshell
    if [[ $SHLVL -gt 1 ]]; then
        return 1
    fi

    local extra_paths_dir
    extra_paths_dir="$(realpath "$1")"
    local -A modified_env_vars

    for extra_paths_file in "${extra_paths_dir}"/*; do
        if [[ -f "$extra_paths_file" ]]; then
            local env_var_name
            env_var_name="$(basename "${extra_paths_file}")"
            env_var_name="${env_var_name%%.*}"

            local extra_paths
            readarray -t extra_paths < <(envsubst < "${extra_paths_file}")  # expand env vars in paths

            modified_env_vars["${env_var_name}"]="$(append_paths "$env_var_name" "${extra_paths[@]}")"
        fi
    done

    for env_var_name in "${!modified_env_vars[@]}"; do
        export "${env_var_name}=${modified_env_vars["$env_var_name"]}"
    done
}

# append paths to env variable
# input argument 1: the env variable name
# input arguments 2...: the paths to be appended
append_paths() {
    local env_var_name="$1"
    shift
    local paths_to_add=($(eval echo \"$@\"))  # expand widlcards
    local -A added_paths
    IFS=':' read -ra existing_paths <<< "${!env_var_name}"
    for path in "${existing_paths[@]}"; do
        if [[ "${path}" ]]; then
            #echo "existing path: $path"
            added_paths["$path"]=1
        fi
    done
    local new_paths_array=()

    for path in "${paths_to_add[@]}"; do
        if [[ "${added_paths["$path"]}" ]]; then
            #echo "Warning: skipped adding existing path \"$path\" in $env_var_name"
            continue
        fi
        if [[ "${path:0:1}" == "#" ]]; then
            #echo "skipped invalid: $path"
            continue
        fi
        #echo -e "appended to $env_var_name: $path"
        new_paths_array+=("$path")
        added_paths["$path"]=1
    done

    new_paths_array+=("${!env_var_name}")
    local IFS=":"
    echo "${new_paths_array[*]}"
}

main "$@"
unset main
unset append_paths
