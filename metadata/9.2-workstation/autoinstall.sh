#!/bin/bash

dest="$ALTERATOR_DESTDIR"
iface="$(ls -1 /sys/class/net/ | grep -v ^lo$ | head -1)"

apt-get -y remove virtualbox-guest-common-vboxguest virtualbox-guest-common-vboxvideo virtualbox-common
rm -f /etc/modules-load.d/virtualbox-addition.conf
rm -f $dest/etc/modules-load.d/virtualbox-addition.conf

mkdir -p "$dest/etc/systemd/system/network.service.d"
echo -e "[Unit]\nRequires=sys-subsystem-net-devices-$iface.device\nAfter=sys-subsystem-net-devices-$iface.device" >$dest/etc/systemd/system/network.service.d/$iface.conf

echo "PasswordAuthentication yes" >> $dest/etc/openssh/sshd_config
echo "PermitRootLogin yes" >> $dest/etc/openssh/sshd_config
