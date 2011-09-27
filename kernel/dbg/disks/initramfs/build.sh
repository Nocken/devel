#!/bin/sh

DIR="romfs"
INITRD="initramfs.bin"
INITRDGZ="$INITRD.gz"
SEARCH_PATH="/lib/tls/i686/sse2/cmov /lib/tls/i686/sse2 /lib/tls/i686/cmov /lib/tls/i686 /lib/tls/sse2/cmov /lib/tls/sse2 /lib/tls/cmov /lib/tls /lib/i686/sse2/cmov /lib/i686/sse2 /lib/i686/cmov /lib/i686 /lib/sse2/cmov /lib/sse2 /lib/cmov /lib"
EXTRA_LIBS="libdl.so.2
	    librt.so.1
            libc.so.6
	    libm.so.6
            libpthread.so.0
            libz.so.1"

get_dep_libs () {
	DEP_LIBS=`ldd busybox/bin/busybox skel/{bin,sbin}/* | grep '^[[:space:]]' | sort | \
		awk '{if (last != $1) {if ("=>" == $2) print $3; else print $1} last=$1;}'`
}

copy_one_lib () {
	if [ -e "$1" ]; then
		cp -uv "$1" "$2"
	else
		local dir
		for dir in $SEARCH_PATH; do
			if [ -f "$dir/$1" ]; then
				cp -uv "$dir/$1" "$2"
				return
			fi
		done
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

