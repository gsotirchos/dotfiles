#!/usr/bin/env bash

for plist_file in "${1}/"*.plist; do
    sudo ln -sfv "${plist_file}"\
        ~/Library/LaunchDaemons/"$(basename ${plist_file})"
    sudo launchctl load -w\
        ~/Library/LaunchDaemons/"$(basename ${plist_file})"
done
