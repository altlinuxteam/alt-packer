PACKER_CACHE_DIR := packer_cache
iso_mount_path = ./distr
packer_bin = $(shell which packer)
arch = x86_64
version = 8.2
headless = true
iso_flavor = 
apt_sources := 8.2
THIS_FILE := $(lastword $(MAKEFILE_LIST))
VM_TYPE := qemu

prepare:
	@echo target is $@, source is $<, TARGET is $(TARGET)
	if mount | grep -q '$(iso_mount_path)[[:space:]]\+type[[:space:]]\+iso9660'; then sudo umount $(iso_mount_path); fi
	sudo mount -o loop $(PACKER_CACHE_DIR)/$(TARGET)-$(version)-$(iso_flavor)$(arch).iso $(iso_mount_path)

fin:
	@echo umount ISO
	if mount | grep -q '$(iso_mount_path)[[:space:]]\+type[[:space:]]\+iso9660'; then sudo umount $(iso_mount_path); fi

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
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@ iso_flavor="install-"
	sudo \
		PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)-install" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_APT_SOURCES="$(apt_sources)" \
		$(packer_bin) build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=kws.$(VM_TYPE) build.json
	@$(MAKE) -f $(THIS_FILE) fin TARGET=$@

alt-workstation:
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@
	sudo \
		PACKER_CACHE_DIR="$(PACKER_CACHE_DIR)" \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_APT_SOURCES="$(apt_sources)" \
		$(packer_bin) build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=ws.$(VM_TYPE) build.json
	@$(MAKE) -f $(THIS_FILE) fin TARGET=$@

srv: alt-server

kw: alt-kworkstation

ws: alt-workstation
