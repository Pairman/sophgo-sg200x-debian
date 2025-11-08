# Debian Images for Sophgo cv181x/sg200x based boards 
This repository builds debian images for Sophgo cv181x/sg200x based boards such as Sipeed LicheeRvNano.

The images aim to be as close to possible to debian best practices as possible

## Flashing the Image

### LicheeRVNano
To flash from linux, either build your own image and then run the following command:
```
sudo dd if=image/(board)_sd.img of=/dev/sdX bs=4M status=progress
```
... or download a image from the releases page, and then run the following command:
```
lz4 -cd (board)_sd.img.lz4 | sudo dd of=/dev/sdX bs=4M status=progress
```

From windows, you can use tools such as balena etcher

where the (board)_sd.img is the image file you want to flash, and /dev/sdX is the device you want to flash to.
(if you build for a different board, the image file name will be different)


## Image Info
Logins: root/rv and debian/rv

(root login is disabled via SSH, login via debian, and SU to root if needed)

### USB Gadget Support
by default, a rndis interface is started on the USB port, and the IP address is
10.x.y.1 - It also starts a DHCP Server on that interface, so your PC should automatically get an IP address in the 10.x.y.z range

To Disable the rndis interface, you can run the following command:
```
rm /boot/usb.rndis
```

There is also a option to start a serial port (ACM) interface instead of the rndis interface, to do this, you can run the following command:
```
rm /boot/usb.rndis
touch /boot/usb.GS0
```

After executing these commands, you need to reboot.

### WiFi on LicheeRVNano
For the LicheeRVNano/DuoS board, WiFi is enabled. To connect to your wifi network, execute the following command (example, use ssid and password of your wifi network):
```
touch /boot/wifi.sta
echo "My WiFi" | tee /boot/wifi.ssid
echo "Pa$$w0rd" /boot/wifi.pass
```

### Ethernet
For Boards with ethernet, they should automatically get a IP address if your network has a DHCP Server. You can configure the 
ethernet port in /etc/network/interfaces.d/end0

### Additional Packages
This image also adds the debian repository for board-related packages so you can install additional repositories. The debian repository is hosted at 
https://sg200x.deb.git.pnxlr.eu.org/deb which pulls down the compiled debian packages from the above github repository occasionally.

Available debian packages:

 - cvi-pinmux-cv181x  
 Contains a tool named cvi_pinmux which allows to change the function of the pins (GPIO, SPI etc.).
 - firmware-aic8800-cv181x  
 Firmware for the on-board WiFi.

…and board-specific packages like:

 - board-support-licheervnano-e  
 Meta package, installs all board-specific packages.
 - cvitek-fsbl-licheervnano  
 The boot loader (including opensbi and u-boot).
 - cvitek-osdrv-licheervnano-kvm  
 Additional kernel drivers (required for camera support etc.).
 - device-key-licheervnano  
 Startup script that sets the Ethernet MAC address and hostname based on the hash off the device uuid.
 - gadget-nic-licheervnano  
 Startup script to setup USB Gadget NCM/RNDIS networking.
 - linux-headers-licheervnano-e  
 The kernel headers for the board.
 - linux-image-licheervnano-e  
 The kernel customized for the board.
 - load-systemko-licheervnano  
 Startup script that loads the additional drivers.
 - sensor-config-licheervnano  
 Configuration files and parameters required to initialize the camera sensor.
 - usb-device-licheervnano  
 Startup script to setup USB gadget devices.
 - wifi-builtin-licheervnano  
 Startup scripts to initialize the on-board WiFi.
 - zram-config-licheervnano  
 Scripts to setup compressed ZRAM devices for overlayfs and zswap.

## Building the Image
To build a stock image with no modifications:
```
podman run --privileged -it --rm -v ./configs/:/configs -v ./image:/output -v ./scripts:/builder ghcr.io/scpcom/sophgo-sg200x-debian:debian make BOARD=licheervnano image
```

The Docker image will build the image and place it in the image directory

addition make targets are available when building:
- image - builds the image
- clean - cleans the build directory
- linux - build a kernel debian package
- fsbl - build the fsbl debain package (that includes cvitek-fsbl, opensbi and u-boot)

## Customizing the Image
The configs directory contains patches, configuration and device tree files that are used to build the image.

The configs/common directory contains the common configuration for all boards, and the configs/licheervnano and configs/duo256 directories contain the board specific configuration.

To add packages to the image, either add the package name in PACKAGES variable of configs/settings.mk or if the packae is specific to a board, add it to the configs/\<board\>/settings.mk file

Patches for the kernel, opensbi, u-boot or fsbl can be placed in configs/common/patches/ or configs/\<board\>/patches/ depending what they are for.

To assist with developing the image, you can get a shell in the docker container by running:
```
docker run --privileged -it --rm -v ./configs/:/configs -v ./image:/output -v ./scripts/:/builder builder /bin/bash
```
inside the container, packages are build in the /builder/ directory, and the rootfs is placed at /rootfs/ directory

# TODO
- DeviceTree Overlay Support
- Possibly mainline kernel support via the sophgo linux for-next repositories
