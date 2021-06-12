#!/usr/bin/env bash

for plist_file in "${1}/"*.plist; do
    sudo ln -sfv "${plist_file}" \
        ~/Library/LaunchAgents/"$(basename ${plist_file})"
    sudo launchctl load -w \
        ~/Library/LaunchAgents/"$(basename ${plist_file})"
done
