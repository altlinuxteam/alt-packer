PACKER_CACHE_DIR := ./packer_cache
packer_bin = $(shell which packer)
arch = x86_64
BASE_VERSION = 8.2
headless = true
TARGET_VERSION := 8.2
target = alt-server
THIS_FILE := $(lastword $(MAKEFILE_LIST))
# VM_TYPE may be
# - qemu
# - vbox
# - onebula
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

image:
	PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
	PACKER_TARGET="$(target)" \
	PACKER_BASE_VERSION="$(BASE_VERSION)" \
	PACKER_ARCH="$(arch)" \
	PACKER_HEADLESS="$(headless)" \
	PACKER_LOG=1 \
	PACKER_TARGET_VERSION="$(TARGET_VERSION)" \
	PACKER_NET_INIT="$(net_init)" \
	PACKER_VM_TYPE="$(VM_TYPE)" \
	$(build_command) -var-file=config/$(target)-$(BASE_VERSION)-$(arch).json -only=$(VM_TYPE)-vm build.json

