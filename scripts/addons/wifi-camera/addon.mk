ifneq ("$(findstring wifi-camera,$(IMAGE_ADDITIONS))$(findstring wifi-camera,$(PACKAGES))","")
BSPFILTER += "wifi-camera"
endif

WIFI_CAMERA_VERSION ?= 1.0.0
WIFI_CAMERA_BUILD ?= 1
WIFI_CAMERA_GIT_URL ?= $(GIT_HOST)/Pairman/sophgo-sg200x-wifi-camera
WIFI_CAMERA_GIT_REF ?= main
WIFI_CAMERA_WORK_DIR = /rootfs/root/source-wifi-camera
WIFI_CAMERA_BUILD_DIR = $(WIFI_CAMERA_WORK_DIR)/sophgo-sg200x-wifi-camera
WIFI_CAMERA_PACKAGE_DIR = $(BUILDDIR)/package/wifi-camera-$(WIFI_CAMERA_VERSION)
WIFI_CAMERA_BV = $(WIFI_CAMERA_VERSION)-$(shell date -u +%Y%m%d)-$(WIFI_CAMERA_BUILD)

$(BUILDDIR)/wifi-camera-prepare-stamp:
	@echo "$(COLOUR_GREEN)Preparing wifi-camera$(END_COLOUR)"
	@rm -rf $(WIFI_CAMERA_WORK_DIR)
	@mkdir -p $(WIFI_CAMERA_WORK_DIR)/
	@cd $(WIFI_CAMERA_WORK_DIR)/ && git clone $(GIT_CLONE_OPTS) $(WIFI_CAMERA_GIT_URL) sophgo-sg200x-wifi-camera
	@cd $(WIFI_CAMERA_BUILD_DIR)/ && git checkout $(WIFI_CAMERA_GIT_REF)
	@touch $@

$(BUILDDIR)/wifi-camera-stamp: $(BUILDDIR)/middleware-package-stamp $(BUILDDIR)/wifi-camera-prepare-stamp
	@echo "$(COLOUR_GREEN)Packaging wifi-camera$(END_COLOUR)"
	@rm -rf $(WIFI_CAMERA_PACKAGE_DIR)
	@mkdir -p $(WIFI_CAMERA_PACKAGE_DIR)/DEBIAN
	@$(MAKE) -C $(WIFI_CAMERA_BUILD_DIR) install \
		DESTDIR=$(WIFI_CAMERA_PACKAGE_DIR) \
		PREFIX=/usr \
		MIDDLEWARE_DIR=$(BUILDDIR)/middleware \
		KERNEL_DIR=$(KERNEL_OUTPUT_DIR) \
		CHIP_ARCH=CV181X \
		CROSS_COMPILE=$(SDK_CROSS_COMPILE_PATH)/bin/$(SDK_CROSS_COMPILE_PREFIX) \
		SYSROOT=$(SDK_CROSS_COMPILE_PATH)/sysroot
	@printf '%s\n' \
		'Package: wifi-camera' \
		'Version: $(WIFI_CAMERA_BV)' \
		'Section: admin' \
		'Priority: optional' \
		'Architecture: $(DEB_ARCH)' \
		'Maintainer: @pairman' \
		'Depends: libc6 (>= 2.34), $(CHIP_VENDOR)-middleware-$(BOARD)' \
		'Description: Camera capture and recording tools for SG200x boards' \
		' Provides camera-frame, camera-stream, and camera-server.' \
		> $(WIFI_CAMERA_PACKAGE_DIR)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build wifi-camera-$(WIFI_CAMERA_VERSION) wifi-camera_$(WIFI_CAMERA_BV)_$(DEB_ARCH).deb
	@cp -p $(BUILDDIR)/package/wifi-camera_$(WIFI_CAMERA_BV)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp -p /output/wifi-camera_$(WIFI_CAMERA_BV)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@[ "$(GIT_REF)" = "develop" ] || rm -rf $(WIFI_CAMERA_WORK_DIR)
	@touch $@
