# Utilities for preparing a new instance from a system image

* scripts/altlinux-newinstance
* scripts/altlinux-newinstance.service

Utilities are added to the target system by executing a script scripts/steps/setup_prepare_new_instance during post-installation

## /usr/sbin/altlinux-newinstance

The script checks with dmidecode the state of the current platform. If the platform has a new UUID, then actions are taken to clear the system of platform-specific data. In particular:
* Generating new /etc/machine-id
* Generating new /var/lib/dbus/machine-id (same as /etc/machine-id)
* Clearing OpenSSH server keys
* Remove current network settings
* Remove 70-persistent-net.rules UDEV rules
* Clearing root password

It may be necessary to add something else in the future

## /lib/systemd/system/altlinux-newinstance.service

Systemd service, which starts early in the system boot phase. It runs altlinux-newinstance script.
