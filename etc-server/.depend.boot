TARGETS = mountkernfs.sh hostname.sh udev keyboard-setup mountdevsubfs.sh console-setup urandom mountall.sh mountall-bootclean.sh hwclock.sh mountnfs.sh mountnfs-bootclean.sh networking checkroot.sh rpcbind nfs-common checkfs.sh checkroot-bootclean.sh bootmisc.sh procps udev-finish kmod kbd
INTERACTIVE = udev keyboard-setup console-setup checkroot.sh checkfs.sh kbd
udev: mountkernfs.sh
keyboard-setup: mountkernfs.sh udev
mountdevsubfs.sh: mountkernfs.sh udev
console-setup: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh kbd
urandom: mountall.sh mountall-bootclean.sh hwclock.sh
mountall.sh: checkfs.sh checkroot-bootclean.sh
mountall-bootclean.sh: mountall.sh
hwclock.sh: mountdevsubfs.sh
mountnfs.sh: mountall.sh mountall-bootclean.sh networking rpcbind nfs-common
mountnfs-bootclean.sh: mountall.sh mountall-bootclean.sh mountnfs.sh
networking: mountkernfs.sh mountall.sh mountall-bootclean.sh urandom procps
checkroot.sh: hwclock.sh keyboard-setup mountdevsubfs.sh hostname.sh
rpcbind: networking mountall.sh mountall-bootclean.sh
nfs-common: rpcbind hwclock.sh
checkfs.sh: checkroot.sh
checkroot-bootclean.sh: checkroot.sh
bootmisc.sh: mountall-bootclean.sh checkroot-bootclean.sh mountnfs-bootclean.sh mountall.sh mountnfs.sh udev
procps: mountkernfs.sh mountall.sh mountall-bootclean.sh udev
udev-finish: udev mountall.sh mountall-bootclean.sh
kmod: checkroot.sh
kbd: mountall.sh mountall-bootclean.sh mountnfs.sh mountnfs-bootclean.sh
