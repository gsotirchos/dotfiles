#!/usr/bin/env bash

#
# ~/bin/power-settings
#

main() {
    # check if ran on an iMac
    if [[ "$(sysctl hw.model)" != *"iMac"* ]]; then
        echo "Warning: these settings are meant to be used for an iMac"
        exit
    fi

    # set some preffered power settings
    sudo pmset -a displaysleep 10
    sudo pmset -a sleep 10
    sudo pmset -a hibernatemode 0 # classic sleep (wake from RAM)
    sudo pmset -a standby 0       # disable hibernating
    sudo pmset -a autopoweroff 0  # disable lower power chipset sleep
    sudo pmset -a disksleep 0     # disable disk spin-down
    sudo pmset -a powernap 0      # disable power nap
    sudo pmset -a autorestart 1   # reboot on power loss

    echo "Power settings modified"
}

main "$@"
unset main
