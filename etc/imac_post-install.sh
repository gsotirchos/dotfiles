## disable user and system zsys snapshots
#echo "- Disabling ZFS zsys snapshots"
#systemctl --user stop zsys-user-savestate.timer
#systemctl --user disable zsys-user-savestate.timer
#sudo mv /etc/apt/apt.conf.d/90_zsys_system_autosnapshot \
#    /etc/apt/apt.conf.d/90_zsys_system_autosnapshot.disabled

## uninstall default wireless driver, and install working one
#echo "============================================================="
#echo "- Install working wireless driver and remove the default"
#echo "============================================================="
sudo apt purge bcmwl-kernel-source
sudo apt-get install -y broadcom-sta-source
sudo apt-get install -y broadcom-sta-dkms
sudo apt-get install -y broadcom-sta-common

## use newer nvidia driver
#echo "============================================================="
#echo " - Install newer nvidia driver (460)"
#echo "============================================================="
#sudo apt install nvidia-driver-460
#
## generate nvidia xorg config file (installed driver)
#if [[ ! -s /etc/X11/xorg.conf ]]; then
#    echo "- Created /etc/X11/xorg.conf"
#    sudo nvidia-xconfig
#fi
#
## enable brightness adjustment and hide NVidia logo on boot
#echo "============================================================="
#echo " - Enable brightness adjustment and hide NVidia logo on boot"
#echo "============================================================="
#vendor_name='    VendorName     "NVIDIA Corporation"'
#brightness_option=\
#'\    Option         "RegistryDwords" "EnableBrightnessControl=1"'
#nologo_option='\    Option         "NoLogo"'
#
#xorg_file="/etc/X11/xorg.conf"
#if (! grep -q "${brightness_option}" "${xorg_file}"); then
#    sed "/${vendor_name}/a\
#    ${brightness_option}\n${nologo_option}"\
#    "${xorg_file}" > ~/xorg.tmp
#else
#    echo "/etc/X11/xorg.conf is OK, didn't modify"
#fi
#
#sudo mv xorg.tmp /etc/X11/xorg.conf

# install some other packages
#echo "============================================================="
#echo " - Install some other packages"
#echo "============================================================="
#sudo apt -y update
#sudo apt -y upgrade
#sudo apt -y dist-upgrade
#sudo apt -y install \
#    tree \
#    vim-gtk3 \
#    xbacklight \
#    light \
#    exfat-fuse \
#    exfat-utils \
#    openssh-server
