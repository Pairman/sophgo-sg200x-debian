$(BUILDDIR)/load-systemko-stamp:
	@echo "$(COLOUR_GREEN)Packaging load-systemko for $(BOARD)$(END_COLOUR)"
	@$(eval LSKV=$(shell echo "-4"))
	@mkdir -p $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)
	@cp -r /builder/deb/load-systemko/* $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/
	@mkdir -pv $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@cp -a addons/load-systemko/S00kmod $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S00kmod
	@cp -a addons/load-systemko/S25wifimod $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S25wifimod
	@if [ "$(BOARD)" = "duo256" ]; then \
		sed -i 's|\tinsmod soph_vo.ko|\t#insmod soph_vo.ko|g' $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/init.d/S00kmod ; \
	fi
	@mkdir -pv $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@cp -a addons/load-systemko/load-systemko*.service $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@cp -a addons/load-systemko/load-wifimod*.service $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/etc/systemd/system/
	@sed -i 's/Architecture: riscv64/Architecture: $(DEB_ARCH)/' $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/DEBIAN/control
	@sed -i 's/Version: 1.0.0/Version: $(OSDRVVERSION)$(LSKV)/' $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/DEBIAN/control
	@sed -i 's/Package: load-systemko/Package: load-systemko-$(BOARD)/' $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/DEBIAN/control
	@chmod +x $(BUILDDIR)/package/load-systemko-$(BOARD)-$(OSDRVVERSION)/DEBIAN/postinst
	@cd $(BUILDDIR)/package/ && dpkg-deb --build load-systemko-$(BOARD)-$(OSDRVVERSION) load-systemko-$(BOARD)_$(OSDRVVERSION)$(LSKV)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/load-systemko-$(BOARD)_$(OSDRVVERSION)$(LSKV)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/load-systemko-*.deb /rootfs/tmp/install/
	@echo "$(COLOUR_GREEN)Installing load-systemko for $(BOARD)$(END_COLOUR)"
	@mkdir -p /rootfs/tmp/install/
	@echo " load-systemko" >> /rootfs/tmp/install/systemd-enable
	@echo " load-wifimod" >> /rootfs/tmp/install/systemd-enable
	@touch $@
