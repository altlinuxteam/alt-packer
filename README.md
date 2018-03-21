# Overview

  This  repository contains `Packer` definitions to build images to boot ALT Linux in virtual environments as KVM, VirtualBox, etc.

# How to use

  You will need privileges to bind `Packer` HTTP server to the port 80 because the netinstaller will wait for http-server only in port 80. Also to works properly installation ISO should be mounted to the `./distr` mountpoint.

```sh
sudo mount -o loop packer_cache/<hash_for_iso>.iso distr/
```

  Then look into `variables.json` and change defaults to desired values. Next you can validate definitions via:

```sh
packer validate -var-file=variables.json build.json
```

## Build server image for Vagrant

```sh
sudo packer build -var-file=variables.json -only=srv.vbox build.json
```

## Build server image for QEmu

```sh
sudo packer build -var-file=variables.json -only=srv.qemu build.json
```
