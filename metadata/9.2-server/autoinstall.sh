#!/bin/bash

dest="$ALTERATOR_DESTDIR"
iface="$(ls -1 /sys/class/net/ | grep -v ^lo$ | head -1)"

apt-get -y remove virtualbox-guest-common-vboxguest virtualbox-guest-common-vboxvideo virtualbox-common
rm -f /etc/modules-load.d/virtualbox-addition.conf
rm -f $dest/etc/modules-load.d/virtualbox-addition.conf

# Enable systemd-networkd service
mkdir -p $dest/etc/systemd/system/multi-user.target.wants/
mkdir -p $dest/etc/systemd/system/sockets.target.wants/
mkdir -p $dest/etc/systemd/system/sysinit.target.wants/
mkdir -p $dest/etc/systemd/system/network-online.target.wants/
ln -s "/lib/systemd/system/systemd-networkd.service" "$dest/etc/systemd/system/dbus-org.freedesktop.network1.service"
ln -s "/lib/systemd/system/systemd-networkd.service" "$dest/etc/systemd/system/multi-user.target.wants/systemd-networkd.service"
ln -s "/lib/systemd/system/systemd-networkd.socket" "$dest/etc/systemd/system/sockets.target.wants/systemd-networkd.socket"
ln -s "/lib/systemd/system/systemd-network-generator.service" "$dest/etc/systemd/system/sysinit.target.wants/systemd-network-generator.service"
ln -s "/lib/systemd/system/systemd-networkd-wait-online.service" "$dest/etc/systemd/system/network-online.target.wants/systemd-networkd-wait-online.service"

# Enable systemd-resolved service
ln -s "/lib/systemd/system/systemd-resolved.service" "$dest/etc/systemd/system/dbus-org.freedesktop.resolve1.service"
ln -s "/lib/systemd/system/systemd-resolved.service" "$dest/etc/systemd/system/multi-user.target.wants/systemd-resolved.service"

# Set systemd-resolved resolv.conf
rm -rf "$dest/etc/resolv.conf"
ln -s "/run/systemd/resolve/resolv.conf" "$dest/etc/resolv.conf"

echo "PasswordAuthentication yes" >> $dest/etc/openssh/sshd_config
echo "PermitRootLogin yes" >> $dest/etc/openssh/sshd_config
