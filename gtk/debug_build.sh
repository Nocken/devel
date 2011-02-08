#!/bin/sh

COMMON_CONFIG_OPTIONS="--enable-debug=yes --prefix=$ROOT"

CFLAGS="-g"
CXXFLAGS="-g"
export CFLAGS CXXFLAGS

extract() {
	local TARGET TYPE
	TARGET=`echo srcs/${1}*`
	echo "================= extract target \"$TARGET\""
	TYPE=`file $TARGET | awk '{printf $2}'`
	case $TYPE in
		gzip)
			tar xzf $TARGET
			;;
		bzip2)
			tar xjf $TARGET
			;;
	esac
}

build() {
	local TARGET
	TARGET=`echo ${1}*`
	if [ ! -d "$TARGET" ]; then
		extract "$1"
		TARGET=`echo ${1}*`
	fi
	shift
	OPTIONS=$@
	echo "================= build target \"$TARGET\""
	cd $TARGET && \
	if [ ! -e target_built ]; then
			./configure $COMMON_CONFIG_OPTIONS $OPTIONS && \
			make && make install && touch target_built || exit 255
	fi && \
	cd .. || \
	exit 1
}

build glib
build gdk-pixbuf
build pango
build atk
build GConf-dbus
build gstreamer
build gst-plugins-base
build gtk+

