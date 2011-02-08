#!/bin/sh

VER="2.91"
SUBVER="2.91.2"
URL=${1:-"http://ftp.gnome.org/pub/gnome/mobile/$VER/$SUBVER/sources"}

rm -f list
wget -q $URL -O - | sed -n "s%.*<a href=\"\(.*bz2\)\".*%$URL/\1%p" > list
# mv the old package into old directory
echo "--------------------------------------------------------------"
mkdir -p old
for old in *bz2; do
	fgrep -q $old list || mv -v $old old
done
# download new entry in list
echo "--------------------------------------------------------------"
list=`cat list`
for url in $list; do
       	wget -c $url
done


