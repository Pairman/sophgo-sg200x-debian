$(BUILDDIR)/duo-pinmux-stamp: $(BUILDDIR)/buildroot-package-stamp
	@echo "$(COLOUR_GREEN)Packaging duo-pinmux for $(BOARD)$(END_COLOUR)"
	@$(eval DUOPINMUXVERSION=$(shell echo "1.0.0"))
	@$(eval BV=$(shell cd $(BUILDDIR)/buildroot && git log -1 --format="%at" | xargs -I{} date -d @{} +-%Y%m%d-${KERNELREV}))
	@mkdir -p $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)
	@cp -r /builder/deb/duo-pinmux/* $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)/
	@mkdir -pv $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)/usr/bin/
	@cp -p $(BR_OUTPUT_DIR)/target/usr/bin/duo-pinmux $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)/usr/bin/duo-pinmux
	@sed -i 's/Architecture: riscv64/Architecture: $(DEB_ARCH)/' $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)/DEBIAN/control
	@sed -i 's/Version: 1.0.0-1/Version: $(DUOPINMUXVERSION)$(BV)/' $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)/DEBIAN/control
	@sed -i 's/Package: duo-pinmux/Package: duo-pinmux-$(BOARD)/' $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)/DEBIAN/control
	@if [ "$(BOARD)" = "duos" ]; then \
		sed -i 's/Duo256/DuoS/' $(BUILDDIR)/package/duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION)/DEBIAN/control ; \
	fi
	@cd $(BUILDDIR)/package/ && dpkg-deb --build duo-pinmux-$(BOARD)-$(DUOPINMUXVERSION) duo-pinmux-$(BOARD)_$(DUOPINMUXVERSION)$(BV)_$(DEB_ARCH).deb
	@cp $(BUILDDIR)/package/duo-pinmux-$(BOARD)_$(DUOPINMUXVERSION)$(BV)_$(DEB_ARCH).deb /output/
	@mkdir -p /rootfs/tmp/install/
	@cp /output/duo-pinmux-$(BOARD)_$(DUOPINMUXVERSION)$(BV)_$(DEB_ARCH).deb /rootfs/tmp/install/
	@touch $@
