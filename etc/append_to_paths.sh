# function to append paths to an environment variable
# fist argument: the name of an environment variable
# second argument: the list of strings-paths to append
append_paths() {
    local global_var_name="$1"
    local current_paths=":${!global_var_name}:"
    shift
    local extra_paths=($(eval echo \"$@\"))
    local appended_paths=":"
    local merged_paths=""

    # group, in reverse order, the rest of the arguments-paths that exist
    for extra_path in "${extra_paths[@]}"; do
        if [[ -d "${extra_path}" ]]; then
            #echo "${extra_path}"
            current_paths="${current_paths//:$extra_path:/:}"
            appended_paths="${appended_paths//:$extra_path:/:}"
            appended_paths="${appended_paths}${extra_path}:"
        fi
    done
    unset extra_path

    # clean-up and merge the paths to the environment variable
    appended_paths="${appended_paths%:}"
    current_paths="${current_paths#:}"
    merged_paths="${appended_paths#:}:${current_paths%:}"
    export "${global_var_name}=${merged_paths%:}"
}

# the main function to call the append_paths() function for every file in the specified directory
# input argument: the directory containing text files,
# each files' contents are appended to the environment variable with the name of the file
main() {
    local extra_paths_dir="$(realpath "$1")"

    for extra_paths_file in "${extra_paths_dir}"/*; do
        local global_var_name="$(basename "${extra_paths_file}")"
        local global_var_name="${global_var_name%%.*}"
        local extra_paths
        readarray -t extra_paths < <(envsubst < "${extra_paths_file}")

        #echo -e "\nappending to \$${global_var_name} from ${extra_paths_file}:"
        append_paths "${global_var_name}" "${extra_paths[@]}"
        #echo -e "--- ${global_var_name}:\n${!global_var_name}"
    done
    unset extra_paths_file

}

main "$@"
unset main
