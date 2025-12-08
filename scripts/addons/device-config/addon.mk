ifneq ($(strip $(ION_SIZE)),0)
ifneq ("$(findstring sensor-config,$(IMAGE_ADDITIONS))","")
BSPDEPENDS += firmware-vcodec-$(CHIP)
endif
endif

$(BUILDDIR)/firmware-vcodec-package-stamp:
	@echo "$(COLOUR_GREEN)Packaging vcodec-firmware for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)
	@cp -r /builder/deb/firmware-vcodec-cv181x/* $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/
	@mkdir -pv $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/usr/share/fw_vcodec/
	@rsync -avpPxH addons/device-config/overlay/usr/share/fw_vcodec/ $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/usr/share/fw_vcodec/
	@sed -i 's/Architecture: riscv64/Architecture: $(DEB_ARCH)/' $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@sed -i 's/Version: 1.0.0/Version: $(MIDDLEWAREVERSION)/' $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@sed -i 's/Package: firmware-vcodec-cv181x/Package: firmware-vcodec-$(CHIP)/' $(BUILDDIR)/package/firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build firmware-vcodec-$(CHIP)-$(MIDDLEWAREVERSION) firmware-vcodec-$(CHIP)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/firmware-vcodec-$(CHIP)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/firmware-vcodec-$(CHIP)*.deb /rootfs/tmp/install/
	@touch $@

firmware-vcodec: $(BUILDDIR)/firmware-vcodec-package-stamp

$(BUILDDIR)/sensor-config-install-stamp:
	@mkdir -pv /rootfs/boot/
	@[ "$(BOARD)" = "licheervnano" -o "$(BOARD)" = "licheea53nano" ] || touch /rootfs/boot/epsilon
	@mkdir -pv /rootfs/usr/share/sensor_config/cfg/param/
	@mkdir -pv /rootfs/usr/share/sensor_config/data/
	@if [ "$(BOARD)" = "licheervnano" -o "$(BOARD)" = "licheea53nano" ]; then \
		cp -p addons/device-config/overlay/usr/share/sensor_config/cfg/param/sipeed_gc4653_30fps_202403261356.bin /rootfs/usr/share/sensor_config/cfg/param/cvi_sdr_bin ; \
	elif [ "$(BOARD)" = "duo256" ]; then \
		cp -p addons/device-config/overlay/usr/share/sensor_config/cfg/param/cvi_sdr_bin_GC2083 /rootfs/usr/share/sensor_config/cfg/param/cvi_sdr_bin && \
		cp -p addons/device-config/overlay/usr/share/sensor_config/data/sensor_cfg_GC2083.ini /rootfs/usr/share/sensor_config/data/sensor_cfg.ini ; \
	elif [ "$(BOARD)" = "duos" ]; then \
		cp -p addons/device-config/overlay/usr/share/sensor_config/cfg/param/cvi_sdr_bin_GC2083 /rootfs/usr/share/sensor_config/cfg/param/cvi_sdr_bin && \
		cp -p addons/device-config/$(BOARD)/usr/share/sensor_config/data/sensor_cfg_GC2083.ini /rootfs/usr/share/sensor_config/data/sensor_cfg.ini ; \
	fi
	@mkdir -p /rootfs/tmp/install/
	@echo " sensor-config" >> /rootfs/tmp/install/systemd-enable
	@touch $@

$(BUILDDIR)/sensor-config-package-stamp:
	@echo "$(COLOUR_GREEN)Packaging sensor-config for $(BOARD)$(END_COLOUR)"
	@mkdir -p $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)
	@cp -r /builder/deb/sensor-config/* $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/
	@mkdir -pv $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/etc/init.d/
	@cp -a addons/device-config/S02config $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/etc/init.d/S02config
	@mkdir -pv $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/etc/systemd/system/
	@cp -a addons/device-config/sensor-config*.service $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/etc/systemd/system/
	@mkdir -pv $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/usr/share/sensor_config/cfg/param/
	@rsync -avpPxH addons/device-config/overlay/usr/share/sensor_config/cfg/param/ $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/usr/share/sensor_config/cfg/param/
	@rm -f $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/usr/share/sensor_config/cfg/param/cvi_sdr_bin
	@mkdir -pv $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/usr/share/sensor_config/data/
	@rsync -avpPxH addons/device-config/overlay/usr/share/sensor_config/data/ $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/usr/share/sensor_config/data/
	@if [ -e addons/device-config/$(BOARD)/usr/share/sensor_config/data ]; then \
		rsync -avpPxH addons/device-config/$(BOARD)/usr/share/sensor_config/data/ $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/usr/share/sensor_config/data/ ; \
	fi
	@rm -f $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/usr/share/sensor_config/data/sensor_cfg.ini
	@sed -i 's/Architecture: riscv64/Architecture: $(DEB_ARCH)/' $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@sed -i 's/Version: 1.0.0/Version: $(MIDDLEWAREVERSION)/' $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@sed -i 's/Package: sensor-config/Package: sensor-config-$(BOARD)/' $(BUILDDIR)/package/sensor-config-$(BOARD)-$(MIDDLEWAREVERSION)/DEBIAN/control
	@cd $(BUILDDIR)/package/ && dpkg-deb --build sensor-config-$(BOARD)-$(MIDDLEWAREVERSION) sensor-config-$(BOARD)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/sensor-config-$(BOARD)_$(MIDDLEWAREVERSION)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/sensor-config-*.deb /rootfs/tmp/install/
	@touch $@

sensor-config: $(BUILDDIR)/sensor-config-install-stamp $(BUILDDIR)/sensor-config-package-stamp

SENSOR_CONFIG_STAMP_DEPS :=
ifneq ($(strip $(ION_SIZE)),0)
SENSOR_CONFIG_STAMP_DEPS += firmware-vcodec
endif
SENSOR_CONFIG_STAMP_DEPS += sensor-config
$(BUILDDIR)/sensor-config-stamp: $(SENSOR_CONFIG_STAMP_DEPS)
	@echo "$(COLOUR_GREEN)Installing sensor-config for $(BOARD)$(END_COLOUR)"
	@touch $@
