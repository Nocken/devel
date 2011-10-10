#!/bin/sh
SCRIPT_PATH=`readlink -f $0`
DIR_TOP=`dirname $SCRIPT_PATH`
VMLINUZ="$DIR_TOP/vmlinuz"
INITRD_IMG="$DIR_TOP/initrd.img"
DISK_IMG="$DIR_TOP/debian.img"
MNT_POINT="/tmp/usbdisk.$$"
SWAP_DIR="/tmp/swapd.$$"
SWAP_FILE="/tmp/swapf.$$"

pre_do() {
	mkdir -p $MNT_POINT
	mkdir -p $SWAP_DIR
	cat > $SWAP_FILE << EOF
# usb boot disk trick start
DEBIAN_IMG=\${rootmnt}/boot/debian.img
DEBIAN_MNT=/debian
if [ -f \$DEBIAN_IMG ]; then
	modprobe loop
	mkdir \$DEBIAN_MNT
	mount -t ext3 \${DEBIAN_IMG} \${DEBIAN_MNT} -o loop
	rootmnt=\$DEBIAN_MNT
fi
# usb boot disk trick end
EOF
}

post_do() {
	rm $SWAP_FILE
	rm -rf $SWAP_DIR
	rmdir $MNT_POINT
}

umount_disk() {
	umount $MNT_POINT
}

mount_disk() {
	mount $DISK_IMG $MNT_POINT -o loop
}

unpack_initrd() {
	pushd $1
	zcat $MNT_POINT/initrd.img | cpio -i
	popd
}

pack_initrd() {
	pushd $1
	find | cpio -o -H newc | gzip > $INITRD_IMG
	cp $MNT_POINT/vmlinuz $VMLINUZ
	popd
}

copy_mod() {
	local mod from to
	mod=$1.ko
	from=$2/lib/modules
	to=$3/lib/modules

	MODLIST=`find $from -name $mod`
	for MOD in $MODLIST; do
		DEST=$to${MOD#$from}
		mkdir -p `dirname $DEST`
		cp $MOD $DEST
	done
}

moddep_fix() {
	local MODLIST VERSION
	MODLIST="
	fat vfat
	loop
	ext3
	nls_cp437 nls_utf8
	"

	for MOD in $MODLIST; do
		copy_mod $MOD $MNT_POINT $SWAP_DIR
	done
	VERSION=`ls $SWAP_DIR/lib/modules`
	depmod -a -e -F $MNT_POINT/boot/System.map-$VERSION -b $SWAP_DIR $VERSION
}

pre_do
mount_disk
unpack_initrd $SWAP_DIR
moddep_fix
vi $SWAP_DIR/init $SWAP_FILE
pack_initrd $SWAP_DIR
umount_disk
post_do

