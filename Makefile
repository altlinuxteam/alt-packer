packer_cache_dir = packer_cache
iso_mount_path = ./distr
arch = x86_64
version = 8.2
headless = true
iso_flavor = 
THIS_FILE := $(lastword $(MAKEFILE_LIST))
VM_TYPE := qemu

prepare:
	@echo target is $@, source is $<, TARGET is $(TARGET)
	if mount | grep -q '$(iso_mount_path)[[:space:]]\+type[[:space:]]\+iso9660'; then sudo umount $(iso_mount_path); fi
	sudo mount -o loop $(packer_cache_dir)/$(TARGET)-$(version)-$(iso_flavor)$(arch).iso $(iso_mount_path)

alt-server:
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@
	sudo \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		packer build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=srv.$(VM_TYPE) build.json

alt-kworkstation:
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@ iso_flavor="install-"
	sudo \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)-install" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		packer build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=kws.$(VM_TYPE) build.json

alt-workstation:
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@
	sudo \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		packer build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=ws.$(VM_TYPE) build.json

srv: alt-server

kw: alt-kworkstation

ws: alt-workstation
