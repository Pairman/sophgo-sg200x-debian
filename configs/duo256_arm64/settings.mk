CHIP=cv181x
UBOOT_CHIP=cv181x
UBOOT_BOARD=milkv_duo256m_sd
BOOT_CPU=aarch64
ARCH=arm64
DDR_CFG=ddr3_1866_x16
ION_SIZE=63
PARTITION_FILE=partition_sd.xml
STORAGE_TYPE=sd
VARIANT?=e

PACKAGES += " udhcpd"

IMAGE_ADDITIONS += "cvi-pinmux"
IMAGE_ADDITIONS += "duo-pinmux"
IMAGE_ADDITIONS += "sensor-config"
IMAGE_ADDITIONS += "device-key"
IMAGE_ADDITIONS += "ethernet-builtin"
IMAGE_ADDITIONS += "load-systemko"
IMAGE_ADDITIONS += "tpusdk"
IMAGE_ADDITIONS += "usb-device"
IMAGE_ADDITIONS += "zram-config"
#IMAGE_ADDITIONS += "aic8800-firmware"