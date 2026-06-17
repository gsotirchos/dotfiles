#!/usr/bin/env bash
set -euo pipefail

main() {
    if [[ $# -ne 2 ]]; then
        echo "Usage: $(basename "$0") <source_dir> <target_dir>" >&2
        exit 1
    fi

    local source_dir="$1"
    local target_dir="$2"
    local domain=""
    local uid=$(id -u)

    if [[ "$target_dir" == "/Library/LaunchDaemons" ]]; then
        domain="system"
    else
        domain="gui/${uid}"
    fi

    for plist_path in "${source_dir}"/*.plist; do
        [[ -e "${plist_path}" ]] || continue
        local plist_name=$(basename "${plist_path}")
        local target_path="${target_dir}/${plist_name}"

        if [[ "${domain}" == "system" ]]; then
            echo "Configuring System Daemon: ${plist_name}"
            sudo cp -fv "${plist_path}" "${target_path}"
            sudo chown root:wheel "${target_path}"
            sudo chmod 644 "${target_path}"
            # Attempt to kickstart/reload
            sudo launchctl bootout "system" "${target_path}" 2> /dev/null || true
            sudo launchctl bootstrap system "${target_path}" || true
        else
            echo "Configuring User Agent: ${plist_name}"
            mkdir -p "${target_dir}"
            ln -sfv "${plist_path}" "${target_path}"
            # Attempt to kickstart/reload
            launchctl bootout "gui/${uid}" "${target_path}" 2> /dev/null || true
            launchctl bootstrap "gui/${uid}" "${target_path}" || true
        fi
    done
}

main "$@"
