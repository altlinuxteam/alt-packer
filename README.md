# Overview

  This  repository contains `Packer` definitions to build images to boot ALT Linux in virtual environments as KVM, VirtualBox, etc.

# How to use

  You will need privileges to bind `Packer` HTTP server to the port 80 because the netinstaller will wait for http-server only in port 80. Also to works properly installation ISO should be mounted to the `./distr` mountpoint.

```sh
sudo mount -o loop packer_cache/<hash_for_iso>.iso distr/
```

  Then look into `variables.json` and change default to desired values. Next you can run packer as usual.

```sh
sudo packer -var-file=variables.json build.json
```

  Builded images will be available in `output/` directory

## Build by exact provider

  When you need image for exact provider, i.e. VirtualBox you can build it via providing exact `provider` name:

```sh
packer build -var-file=variables.json -only=virtualbox-iso build.json
```

