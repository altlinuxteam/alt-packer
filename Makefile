packer_cache_dir = packer_cache
iso_mount_path = ./distr
arch = x86_64
version = 8.2
headless = true
iso_flavor = 
apt_sources := 8.2
THIS_FILE := $(lastword $(MAKEFILE_LIST))
VM_TYPE := qemu
# on-error may be:
# - abort - stop and leave everything "as is"
# - cleanup - is the default behavior
# - ask - ask what to do
onerror = cleanup
build_command = packer build -var-file=config/common.json -on-error=$(onerror)

prepare:
	@mkdir -p "$(iso_mount_path)"
	@echo target is $@, source is $<, TARGET is $(TARGET)
	if mount | grep -q '$(iso_mount_path)[[:space:]]\+type[[:space:]]\+iso9660'; then sudo umount $(iso_mount_path); fi
	sudo mount -o loop $(packer_cache_dir)/$(TARGET)-$(version)-$(iso_flavor)$(arch).iso $(iso_mount_path)

download:
	@mkdir -p "$(iso_mount_path)"

alt-server:
	./iso_download "./config/$@-$(version)-$(arch).json"
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@
	sudo \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_APT_SOURCES="$(apt_sources)" \
		packer build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=srv.$(VM_TYPE) build.json

alt-kworkstation:
	./iso_download "./config/$@-$(version)-$(arch).json"
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@ iso_flavor="install-"
	sudo \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)-install" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_APT_SOURCES="$(apt_sources)" \
		packer build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=kws.$(VM_TYPE) build.json

alt-workstation:
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=$@
	sudo \
		PACKER_TARGET="$@" \
		PACKER_VERSION="$(version)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		PACKER_APT_SOURCES="$(apt_sources)" \
		packer build -var-file=config/$@-$(version)-$(arch).json -var-file=config/common.json -only=ws.$(VM_TYPE) build.json

alt-server-sp:
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=alt-server version=8sp
	sudo \
		PACKER_TARGET="alt-server-sp" \
		PACKER_VERSION="$(version)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		$(build_command) -var-file=config/alt-server-8sp-$(arch).json -only=$(VM_TYPE).8sp-srv builders/alt-server-8sp-x86_64.json

alt-workstation-sp:
	@$(MAKE) -f $(THIS_FILE) prepare TARGET=alt-workstation version=8sp
	sudo \
		PACKER_TARGET="alt-workstation-sp" \
		PACKER_VERSION="$(version)" \
		PACKER_ARCH="$(arch)" \
		PACKER_HEADLESS="$(headless)" \
		PACKER_LOG=1 \
		$(build_command) -var-file=config/$@-8sp-$(arch).json  -only=$(VM_TYPE).8sp-ws builders/$@-8sp-x86_64.json

srv: alt-server

kw: alt-kworkstation

ws: alt-workstation
