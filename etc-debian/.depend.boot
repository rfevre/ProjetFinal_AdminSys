TARGETS = mountkernfs.sh hostname.sh udev keyboard-setup mountdevsubfs.sh console-setup mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh x11-common kbd networking urandom rpcbind nfs-common hwclock.sh checkroot.sh lm-sensors bootmisc.sh checkfs.sh checkroot-bootclean.sh kmod procps udev-finish
INTERACTIVE = udev keyboard-setup console-setup kbd checkroot.sh checkfs.sh
udev: mountkernfs.sh
keyboard-setup: mountkernfs.sh udev
mountdevsubfs.sh: mountkernfs.sh udev
console-setup: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh kbd
mountall.sh: checkfs.sh checkroot-bootclean.sh
mountall-bootclean.sh: mountall.sh
mountnfs.sh: mountall.sh mountall-bootclean.sh networking rpcbind nfs-common
mountnfs-bootclean.sh: mountall.sh mountall-bootclean.sh mountnfs.sh
x11-common: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
kbd: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
networking: mountkernfs.sh mountall.sh mountall-bootclean.sh urandom procps
urandom: mountall.sh mountall-bootclean.sh hwclock.sh
rpcbind: networking mountall.sh mountall-bootclean.sh
nfs-common: rpcbind hwclock.sh
hwclock.sh: mountdevsubfs.sh
checkroot.sh: hwclock.sh mountdevsubfs.sh hostname.sh keyboard-setup
lm-sensors: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
bootmisc.sh: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh udev checkroot-bootclean.sh
checkfs.sh: checkroot.sh
checkroot-bootclean.sh: checkroot.sh
kmod: checkroot.sh
procps: mountkernfs.sh mountall.sh mountall-bootclean.sh udev
udev-finish: udev mountall.sh mountall-bootclean.sh
