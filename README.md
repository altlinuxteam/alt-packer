# Packer VM image build instructions

## Contents

* [Overview](#overview)
* [Preparation](#preparation)
* [Building images](#building-images)
* [Troubleshooting](#troubleshooting)

* * *


# Overview

This  repository contains `Packer` definitions to build images to boot
ALT Linux in virtual environments as KVM, VirtualBox, etc.

# Preparation

Update the kernel like:

```sh
sudo update-kernel
```

and reboot to take advantage of new kernel packages.

Install the following dependencies:

* **make**
* **jq**
* **curl**
* **qemu-kvm**
* **qemu-ui-sdl**
* **virtualbox**
* **packer**
* **kernel-modules-kvm-std-def**
* **kernel-modules-virtualbox-std-def**

and add the necessary kernel module to the list of modules to load:

For Intel:

```sh
echo kvm_intel >> /etc/modules
```

For AMD:

```sh
echo kvm_amd >> /etc/modules
```

You will also need to add user to `vmusers` group for **QEMU**:

```sh
usermod -aG vmusers username
```

You will also need **VirtualBox** service working and the user added
into **VirtualBox** group:

```
usermod -aG vboxadd,vboxusers username
systemctl enable virtualbox
systemctl start virtualbox
```

Then reboot the machine.

* Create the `packer_cache` directory (or symlink it) and download the
necessary ISOs into it.

## Building images

You may start building image for **QEMU** like:

```sh
make image target=alt-workstation headless=false BASE_VERSION=9 TARGET_VERSION=9 VM_TYPE=qemu
```

or if you want to build image for **VirtualBox**:

```sh
make image target=alt-server headless=false BASE_VERSION=9 TARGET_VERSION=9 VM_TYPE=vbox
```


## Troubleshooting

In case of problems with autoinstaller add `instdebug` option to
kernel boot parameters.


