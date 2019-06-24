# Packer VM image build instructions

## Contents

* [Overview](#overview)
* [Preparation](#preparation)
* [Builders](#builders)
  * [ALT Linux 8 SP Server](builders/alt-server-8sp-x86_64.json)
  * [ALT Linux 8 SP Workstation](builders/alt-workstation-8sp-x86_64.json)
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
* Create the `./distr` directory which will serve as a mountpoint.

  You will need privileges to bind `Packer` HTTP server to the port 80 because the netinstaller will wait for http-server only in port 80. Also to works properly installation ISO should be mounted to the `./distr` mountpoint.

```sh
sudo mount -o loop packer_cache/<hash_for_iso>.iso distr/
```

  Then look into `variables.json` and change defaults to desired values. Next you can validate definitions via:

```sh
packer validate -var-file=variables.json build.json
```

## Builders

You may start building image for **QEMU** like:

```sh
make alt-server-sp headless=false VM_TYPE=qemu
```

or if you want to build image for **VirtualBox**:

```sh
make alt-workstation-sp headless=false VM_TYPE=vbox
```


## Build server image for Vagrant

```sh
sudo packer build -var-file=variables.json -only=srv.vbox build.json
```

## Build server image for QEmu

```sh
sudo packer build -var-file=variables.json -only=srv.qemu build.json
```

## Troubleshooting

In case of problems with autoinstaller add `instdebug` option to
kernel boot parameters.


