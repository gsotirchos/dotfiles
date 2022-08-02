#!/usr/bin/env bash

main() {
    for plist_file in "${1}"/*.plist; do
        ln -sfv "${plist_file}" \
            ~/Library/LaunchAgents/"$(basename "${plist_file}")"
        launchctl unload -w \
            ~/Library/LaunchAgents/"$(basename "${plist_file}")"
        launchctl load -w \
            ~/Library/LaunchAgents/"$(basename "${plist_file}")"
    done
}

main "$@"
unset main
