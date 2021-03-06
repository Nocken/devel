#!/bin/sh
FS="ext3"
IMG="sda.img"
MNT="rootfs"
MNTFLAG=".mounted"

TAPDEV="tapvm"
TAPIP="10.3.2.1"
TAPNET="10.3.2.0"
TAPMASK="24"

POS=`readlink -f $0`
TOP=`dirname $POS`
LINUXDIR="$TOP/linux"
BZIMAGE="$LINUXDIR/arch/x86/boot/bzImage"
VMIMAGE="$LINUXDIR/vmlinux"
KERNEL="$BZIMAGE"
INITRD="$TOP/disks/initramfs/initramfs.bin.gz"
NFSMNT="$TOP/mnt"

chroot_param() {
	if [ $# -gt 0 ]; then
		IMG="$1"
	else
		IMG="sda.img"
	fi
	if [ $# -gt 1 ]; then
		MNT="$2"
	else
		MNT="rootfs"
	fi
}

pre_chroot() {
	sudo sh -c \
	"
	touch $MNTFLAG
	mount -vt $FS $IMG $MNT -o loop
	mount -v --bind /dev $MNT/dev
	mount -v --bind /tmp $MNT/tmp
	mount -vt devpts devpts $MNT/dev/pts
	mount -vt tmpfs shm $MNT/dev/shm
	mount -vt proc proc $MNT/proc
	mount -vt sysfs sysfs $MNT/sys
	"
}

post_chroot() {
	sudo sh -c \
	"
	umount -v $MNT/sys
	umount -v $MNT/proc
	umount -v $MNT/dev/shm
	umount -v $MNT/dev/pts
	umount -v $MNT/tmp
	umount -v $MNT/dev
	umount -v $MNT
	rm -f $MNTFLAG
	"
}

chroot() {
	chroot_param "$@"
	pre_chroot
	sudo sh -c \
	"
	chroot "$MNT" /usr/bin/env -i \
	HOME=/root TERM="$TERM" PS1='\u:\W\$ ' \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin \
	/bin/bash --login
	"
	post_chroot
}

sync_root() {
	local valid;
	valid=0;
	while [ ! $# -eq 0 ]; do
		if [ -d "$1" ]; then
			if [ $valid -eq 0 ]; then
				pre_chroot;
			fi
			valid=1;
			sudo cp -drvT $1 $MNT
		else
			echo "'$1' is not a valid directory path."
		fi
		shift;
	done
	if [ $valid -eq 1 ]; then
		post_chroot;
	else
		echo "usage: sync directorys into the rootfs"
		return 1
	fi
	return 0
}

init() {
	ln -sT $NFSMNT /tmp/nfs
	sudo sh -c \
	"
	tunctl -u ${USER} -t ${TAPDEV}
	ip link set dev ${TAPDEV} up
	ip addr add ${TAPIP}/${TAPMASK} dev ${TAPDEV}
	sysctl -e -w net.ipv4.ip_forward=1
	iptables -t nat -A POSTROUTING -s ${TAPNET}/${TAPMASK} -j MASQUERADE
	#/etc/init.d/dhcp3-server start
	"
}

uninit() {
	sudo sh -c \
	"
	#/etc/init.d/dhcp3-server stop
	iptables -t nat -F
	sysctl -e -w net.ipv4.ip_forward=0
	ip addr flush dev ${TAPDEV}
	ip link set dev ${TAPDEV} down
	tunctl -d ${TAPDEV}
	"
	rm -f /tmp/nfs
}

VMPARAMS=" \
	-k en-us \
	-m 512 \
	-rtc base=utc \
	-net nic,vlan=0 \
	-net tap,vlan=0,ifname=${TAPDEV},script=no,downscript=no \
	"

#VMPARAMS="$VMPARAMS -vga std"
#VMPARAMS="$VMPARAMS -soundhw ac97"

#KPARAMS="root=/dev/sda"
#KPARAMS="vga=0x315 logo.nologo=1"
KPARAMS=""

VM="kvm"
RUN="$VM $VMPARAMS"

split_param () {
	while [ x"$1" != x ]; do
		case $1 in
			-append)
				shift
				KP="$KP $1"
				;;
			*)
				VP="$VP $1"
				;;
		esac
		shift
	done
}

fix_param () {
	VP="$VMPARAMS"
	KP="$KPARAMS"
	if [ -e $KERNEL ]; then
		VP="$VP -kernel $KERNEL"
	fi
	if [ -e $INITRD ]; then
		VP="$VP -initrd $INITRD"
	fi
	split_param "$@"
}

run () {
	if [ -e $MNTFLAG ]; then
		echo "image have been mounted, umount it first!"	
	else
		fix_param "$@"
		echo $VM $VP -append "$KP"
		$VM $VP -append "$KP"
	fi
}

dbg () {
	VP="-nographic -s"
	KP="console=ttyS0"
	split_param "$@"
	run $VP -append "$KP"
}

qdbg () {
	VM=qemu
	VP="-S"
	KP="HOTPLUG=mdev"
	split_param "$@"
	dbg $VP -append "$KP"
	VM=kvm
}

if [ x$1 != x ]; then
	"$@"
fi
