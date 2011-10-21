#!/bin/sh
SCRIPT_PATH=`readlink -f $0`
DIR_TOP=`dirname $SCRIPT_PATH`
VMLINUZ="$DIR_TOP/vmlinuz"
INITRD_IMG="$DIR_TOP/initrd.img"
ISO_IMG="$DIR_TOP/BT.iso"
MNT_POINT="/tmp/iso.$$"
SWAP_DIR="/tmp/swapd.$$"
INITRD_PATCH="$DIR_TOP/initrd.patch"

pre_do() {
	mkdir -p $MNT_POINT
	mkdir -p $SWAP_DIR
	sudo mount $ISO_IMG $MNT_POINT -o loop
}

post_do() {
	sudo umount $MNT_POINT
	rm -rf $SWAP_DIR
	rmdir $MNT_POINT
}

unpack_initrd() {
	RET=1
	pushd $2
	zcat $1 | cpio -i && RET=0
	popd
	return $RET
}

pack_initrd() {
	RET=1
	pushd $2
	find | cpio -o -H newc | gzip > $1 && RET=0
	popd
	return $RET
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

clean_dir() {
	rm -rf $1 && \
	mkdir $1
}

transform_dir() {
	RET=1
	pushd $1
	patch -p1 < $INITRD_PATCH && RET=0
	# bugfix: need give the new added file execute permission
	chmod +x scripts/casper-premount/20usbdisk_mount
	popd
	#moddep_fix
	return $RET
}

pre_do

echo "copy splash image"
cp -v "$MNT_POINT/isolinux/splash.png" "$DIR_TOP"
echo "copy the kernel image"
cp -v "$MNT_POINT/casper/vmlinuz" "$DIR_TOP"
# transform the iso initrd to support usbdisk boot up
echo "transform the initrd.img"
INITRD_LIST=$(echo $MNT_POINT/casper/initrd*.gz)
for INITRD in $INITRD_LIST; do
	INITRD_NEW="$DIR_TOP/$(basename $INITRD)"
	clean_dir $SWAP_DIR && \
	unpack_initrd $INITRD $SWAP_DIR && \
	transform_dir $SWAP_DIR && \
	pack_initrd $INITRD_NEW $SWAP_DIR
done
# transform isolinux.cfg into usbdisk syslinux.cfg
echo "transform the syslinux.cfg"
sed 's/CD/USB/g; s%/casper/%%g; s%/isolinux/%%g' "$MNT_POINT/isolinux/isolinux.cfg" > "$DIR_TOP"/syslinux.cfg

post_do

