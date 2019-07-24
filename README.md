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


## Troubleshooting

In case of problems with autoinstaller add `instdebug` option to
kernel boot parameters.


