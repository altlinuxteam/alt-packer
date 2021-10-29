PACKER_CACHE_DIR := ./packer_cache
arch = x86_64
BASE_VERSION = 9.2
headless = true
TARGET_VERSION := 9.2
target = alt-server
THIS_FILE := $(lastword $(MAKEFILE_LIST))
# VM_TYPE may be
# - qemu
# - vbox
# - onebula
VM_TYPE := qemu
# on-error may be:
# - abort - stop and leave everything "as is"
# - cleanup - is the default behavior
# - ask - ask what to do
onerror = cleanup
organization = BaseALT

# Build base VM box using Packer
image:
	PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
	PACKER_TARGET="$(target)" \
	PACKER_BASE_VERSION="$(BASE_VERSION)" \
	PACKER_ARCH="$(arch)" \
	PACKER_HEADLESS="$(headless)" \
	PACKER_LOG=1 \
	PACKER_TARGET_VERSION="$(TARGET_VERSION)" \
	PACKER_VM_TYPE="$(VM_TYPE)" \
	./build_vm

# Publish previously built VM box using Vagrant. Please note that you'll
# need to provide TOKEN from Vagrant Cloud as environment variable.
publish:
	target="$(target)" \
	arch="$(arch)" \
	BASE_VERSION="$(BASE_VERSION)" \
	TARGET_VERSION="$(TARGET_VERSION)" \
	VM_TYPE="$(VM_TYPE)" \
	./publish_vm

# Download images specified in JSON configuration files.
sync:
	PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
	./sync_images

