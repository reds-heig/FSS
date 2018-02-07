#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

# Patch QEmu and compile it
rm ../qemu/hw/fss -rf
if ! cmp ../qemu_patch/Makefile.objs ../qemu/hw/Makefile.objs >/dev/null 2>&1
then
    cp ../qemu_patch/Makefile.objs ../qemu/hw/Makefile.objs
fi
cp ../qemu_patch/fss ../qemu/hw -r
cp ../include/fss_qemu_common.* ../qemu/hw/fss
cp ../qemu_patch/versatilepb.c ../qemu/hw/arm
cd ../qemu/
./configure --target-list=arm-softmmu --disable-user --enable-sdl --python=python2
patch -l -p2 < ../qemu_perl.patch
make -j 8
mkdir -p ../bin
cp arm-softmmu/qemu-system-arm ../bin/qemu_fss
cd ../scripts
