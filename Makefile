PACKER_CACHE_DIR := packer_cache
iso_mount_path = ./distr
packer_bin = $(shell which packer)
arch = x86_64
version = 8.2
headless = true
apt_sources := 8.2
THIS_FILE := $(lastword $(MAKEFILE_LIST))
VM_TYPE := qemu

alt-server:
	PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
	PACKER_TARGET="$@" \
	PACKER_VERSION="$(version)" \
	PACKER_ARCH="$(arch)" \
	PACKER_HEADLESS="$(headless)" \
	PACKER_LOG=1 \
	PACKER_APT_SOURCES="$(apt_sources)" \
	$(packer_bin) build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=srv.$(VM_TYPE) build.json

alt-kworkstation:
	PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
	PACKER_TARGET="$@" \
	PACKER_VERSION="$(version)-install" \
	PACKER_ARCH="$(arch)" \
	PACKER_HEADLESS="$(headless)" \
	PACKER_LOG=1 \
	PACKER_APT_SOURCES="$(apt_sources)" \
	$(packer_bin) build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=kws.$(VM_TYPE) build.json

alt-workstation:
	PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
	PACKER_TARGET="$@" \
	PACKER_VERSION="$(version)" \
	PACKER_ARCH="$(arch)" \
	PACKER_HEADLESS="$(headless)" \
	PACKER_LOG=1 \
	PACKER_APT_SOURCES="$(apt_sources)" \
	$(packer_bin) build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=ws.$(VM_TYPE) build.json

srv: alt-server

kw: alt-kworkstation

ws: alt-workstation
