#!/bin/sh

DIR="romfs"
INITRD="initramfs.bin"
INITRDGZ="$INITRD.gz"
EXTRA_LIBS="/lib/libpthread.so.0"

get_dep_libs () {
	DEP_LIBS=`ldd busybox/bin/busybox skel/{bin,sbin}/* | grep '^[[:space:]]' | sort | \
		awk '{if (last != $1) {if ("=>" == $2) print $3; else print $1} last=$1;}'`
}

copy_one_lib () {
	if [ -e "$1" ]; then
		cp -uv "$1" "$2"
	fi
}

update_libs () {
	get_dep_libs
	for lib in $DEP_LIBS; do
		copy_one_lib "$lib" "skel/lib"
	done
	for lib in $EXTRA_LIBS; do
		copy_one_lib "$lib" "skel/lib"
	done
}

update_libs
rm -rf $DIR
cp -a busybox $DIR
cp -aT skel $DIR
cd $DIR && find . | cpio -H newc -o | tee ../$INITRD | gzip - > ../$INITRDGZ

