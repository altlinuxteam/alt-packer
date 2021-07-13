# Packer VM image build instructions

## Contents

* [Overview](#overview)
* [Preparation](#preparation)
* [Building images](#building-images)
* [Publishing images](#publishing-images)
* [Syncing images](#syncing-images)
* [Using images with Vagrant](#using-images-with-vagrant)
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
* **wget**
* **qemu-kvm**
* **qemu-ui-sdl**
* **virtualbox**
* **packer**
* **vagrant** (only if you plan to distribute boxes via Vagrant Cloud)
* **kernel-modules-kvm-std-def**
* **kernel-modules-virtualbox-std-def**
* **nbd-client**, **nbd-server** (if you plan to transfer images using NBD)

and add the necessary kernel module to the list of modules to load:

For Intel:

```sh
echo kvm_intel >> /etc/modules-load.d/kvm.conf
```

For AMD:

```sh
echo kvm_amd >> /etc/modules/kvm.conf
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


## Publishing images

You may publish previously built boxes using **Vagrant** software like:

```sh
export VAGRANTCLOUD_TOKEN="my_cloud_auth_token"
make publish orgname=myorg target=alt-server VM_TYPE=vbox BASE_VERSION=9 TARGET_VERSION=9
make publish orgname=myorg target=alt-workstation VM_TYPE=qemu BASE_VERSION=9 TARGET_VERSION=9
```


## Syncing images

In order to keep images up-to-date there is `sync_images` script
provided in the repository. It parses the corresponding ditro
configuration files and checks if the necessary images are provided in
the `./packer_cache` directory. It's advised to set up to start this
script using `crond` in order to keep images synchronized.

It is also possible to invoke the script using `make sync` command.


## Using images with Vagrant

You may find **Vagrantfile** templates in `vagrant` directory. Just go
into subdirectory corresponding to the box you want to start and type

```sh
vagrant up
```

## Deploying images to Proxmox

First export QCOW2 image from build machine using NBD (on port 12345):

```sh
nbd-server 12345 /mnt/disk/alt-packer/qemu-alt-server-9-amd64/qemu-alt-server-9-amd64
```

On the client you need to issue command to connect to NBD server
(assuming server IP is 192.168.1.101):

```sh
nbd-client -D 192.168.1.101 12345
```

On client, you may check that QCOW2 image is mounted using these
commands:

```sh
file -s /dev/nbd0
```

or better:

```sh
qemu-img info /dev/nbd0
```

Then (on client) use `qemu-img` utility to transfer image to block
device of your choice:

```sh
qemu-img dd bs=1M if=/dev/nbd0 of=/dev/pve/zvol/vm-100-disk-1
```

This may take quite a time because of large file transfer.

Then disconnect the client:

```sh
nbd-client -d /dev/nbd0
```

and stop the server with SIGINT (pressing Ctrl+C).

## Troubleshooting

* In case of problems with autoinstaller add `instdebug` option to
kernel boot parameters.
* In case of errors like `No space left on device` when using `/tmp`
directory - set `TMPDIR` variable to another location.

