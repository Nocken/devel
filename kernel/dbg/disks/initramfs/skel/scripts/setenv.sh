#!/bin/sh
HOST="10.3.2.1"
MNTENTRY="$HOST:/home/ken/developer/workspace/linux_x86/mnt"
MNTPOINT="/mnt"
mount $MNTENTRY $MNTPOINT -o nolock

