#!/opt/pkg/bin/bash

# set some preffered power settings
sudo pmset -a standby 1         # enable safe slep (hibernate)
sudo pmset -a hibernatemode 3    # RAM on sleep, disk on safe sleep
sudo pmset -a standbydelay 5400 # sleep for 1.5 hours before safe sleep
sudo pmset -a autorestart 1     # reboot on poert loss
sudo pmset -a autopoweroff 0    # disable mandatory safe sleep

echo "power settings modified"
