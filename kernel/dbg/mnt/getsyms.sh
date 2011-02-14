#!/bin/sh

if [ $# -lt 1 ]; then
	echo Usage: $0 module
	exit
fi

MODULEFILE=$1
MODULEFILEBASENAME=`basename $1 .ko`
SECTIONDIR="/sys/module/$MODULEFILEBASENAME/sections"
SECTIONS=$(echo $SECTIONDIR/.* $SECTIONDIR/*)

for sec in $SECTIONS; do
	test -f $sec || continue;
	mod=$(basename $sec) 
	addr=$(cat $sec)
	case $mod in
		.text)
			TEXTADDR="$addr"
			;;
		*)
			SEGADDRS="$SEGADDRS -s $mod $addr"
			;;
	esac
done

LOADSTRING="add-symbol-file $MODULEFILE $TEXTADDR"
LOADSTRING="$LOADSTRING $SEGADDRS"
echo $LOADSTRING 
