#!/bin/sh
ROOT=${1:-"$HOME/Workspace/root"}
echo "set root=$ROOT"
CPPFLAGS="-I$ROOT/include"
LDFLAGS="-L$ROOT/lib"
PKG_CONFIG_PATH="$ROOT/lib/pkgconfig"
export CPPFLAGS LDFLAGS PKG_CONFIG_PATH ROOT
    
LD_LIBRARY_PATH="$ROOT/lib"
PATH="$ROOT/bin:$PATH"
export LD_LIBRARY_PATH PATH

unset GTK_MODULES

