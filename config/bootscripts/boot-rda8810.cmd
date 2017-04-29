# DO NOT EDIT THIS FILE
#
# Please edit /boot/armbianEnv.txt to set supported parameters
#

# default values
setenv verbosity "1"

if test "${boot_device}" = "mmc"; then

	setenv rootdev "/dev/mmcblk0p2"
	setenv rootfstype "ext4"

	if ext2load mmc 0:1 ${load_addr} armbianEnv.txt; then
		env import -t ${load_addr} ${filesize}
	fi

	setenv bootargs "root=${rootdev} rootwait rootfstype=${rootfstype} console=ttyS0,921600 panic=10 consoleblank=0 loglevel=${verbosity} ${extraargs} ${extraboardargs}"

	ext2load mmc 0:1 ${initrd_addr} uInitrd
	ext2load mmc 0:1 ${kernel_addr} zImage
	ext2load mmc 0:1 ${modem_addr} modem.bin
	ext2load mmc 0:1 ${factorydata_addr} factorydata.img
else
	echo "NAND boot is not implemented yet"
fi

# modem init is mandatory according to u-boot sources
mdcom_cal_loadm ${factorydata_addr}
mdcom_loadm ${modem_addr}
mdcom_check 1

bootz ${kernel_addr} ${initrd_addr}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr
