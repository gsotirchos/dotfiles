#!/usr/bin/env bash
set -euo pipefail

main() {
    local profile_src
    profile_src="$(dirname "$(realpath "${BASH_SOURCE[0]}")")/apparmor/bwrap"

    sudo cp "${profile_src}" /etc/apparmor.d/bwrap
    sudo apparmor_parser -r /etc/apparmor.d/bwrap

    # Failed thumbnails are cached and never retried until the file changes.
    rm -rf "${XDG_CACHE_HOME:-${HOME}/.cache}/thumbnails/fail"
    nautilus -q 2> /dev/null || true
}

main "$@"
