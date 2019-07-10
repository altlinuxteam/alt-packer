PACKER_CACHE_DIR := packer_cache
iso_mount_path = ./distr
packer_bin = $(shell which packer)
arch = x86_64
BASE_VERSION = 8.2
headless = true
TARGET_VERSION := 8.2
THIS_FILE := $(lastword $(MAKEFILE_LIST))
VM_TYPE := qemu
# net_init may be:
# - cloud-init - Use cloud-init scripts
# - empty - don't do anything
net_init =
# on-error may be:
# - abort - stop and leave everything "as is"
# - cleanup - is the default behavior
# - ask - ask what to do
onerror = cleanup
build_command = $(packer_bin) build -var-file=config/common.json -on-error=$(onerror)

prepare:
	@mkdir -p "$(iso_mount_path)"
	@echo target is $@, source is $<, TARGET is $(TARGET)
	if mount | grep -q '$(iso_mount_path)[[:space:]]\+type[[:space:]]\+iso9660'; then sudo umount $(iso_mount_path); fi
	sudo mount -o loop $(PACKER_CACHE_DIR)/$(TARGET)-$(BASE_VERSION)-$(iso_flavor)$(arch).iso $(iso_mount_path)

download:
	@mkdir -p "$(iso_mount_path)"

alt-server:
	env \
		PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
		PACKER_TARGET="$@" \
		PACKER_BASE_VERSION="$(BASE_VERSION)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_TARGET_VERSION="$(TARGET_VERSION)" \
		PACKER_NET_INIT="$(net_init)" \
		$(build_command) -var-file=config/$@-$(BASE_VERSION)-$(arch).json -only=srv.$(VM_TYPE) build.json

alt-kworkstation:
	env \
		PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
		PACKER_TARGET="$@" \
		PACKER_BASE_VERSION="$(BASE_VERSION)-install" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_TARGET_VERSION="$(TARGET_VERSION)" \
		PACKER_NET_INIT="$(net_init)" \
		$(build_command) -var-file=config/$@-$(BASE_VERSION)-$(arch).json -only=kws.$(VM_TYPE) build.json

alt-workstation:
	env \
		PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
		PACKER_TARGET="$@" \
		PACKER_BASE_VERSION="$(BASE_VERSION)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_TARGET_VERSION="$(TARGET_VERSION)" \
		PACKER_NET_INIT="$(net_init)" \
		$(build_command) -var-file=config/$@-$(BASE_VERSION)-$(arch).json -only=ws.$(VM_TYPE) build.json

alt-server-build:
	env \
		PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
		PACKER_TARGET="alt-server" \
		PACKER_BASE_VERSION="$(BASE_VERSION)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_TARGET_VERSION="8sp" \
		PACKER_NET_INIT="$(net_init)" \
		$(build_command) -var-file=config/alt-server-$(BASE_VERSION)-$(arch).json -only=$(VM_TYPE).$(BASE_VERSION)-srv builders/alt-server-$(BASE_VERSION)-$(arch).json

alt-workstation-build:
	env \
		PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
		PACKER_TARGET="alt-workstation" \
		PACKER_BASE_VERSION="$(BASE_VERSION)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_TARGET_VERSION="8sp" \
		PACKER_NET_INIT="$(net_init)" \
		$(build_command) -var-file=config/alt-workstation-$(BASE_VERSION)-$(arch).json  -only=$(VM_TYPE).$(BASE_VERSION)-ws builders/alt-workstation-$(BASE_VERSION)-$(arch).json

srv: alt-server

kws: alt-kworkstation

ws: alt-workstation

