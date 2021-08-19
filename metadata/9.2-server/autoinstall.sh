#!/bin/bash

apt-get remove -y virtualbox-common-

dest="$ALTERATOR_DESTDIR"
iface="$(ls -1 /sys/class/net/ | grep -v ^lo$ | head -1)"

mkdir -p "$dest/etc/systemd/system/network.service.d"
echo -e "[Unit]\nRequires=sys-subsystem-net-devices-$iface.device\nAfter=sys-subsystem-net-devices-$iface.device" >$dest/etc/systemd/system/network.service.d/$iface.conf
