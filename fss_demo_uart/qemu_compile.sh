#!/bin/bash
# FSS serial port demo - build script
#
# FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH)
# Alberto Dassatti, Anthony Convers, Roberto Rigamonti, Xavier Ruppen -- 11.2015

# Patch QEmu and compile it
rm qemu/hw/fss -rf
if ! cmp qemu_patch/Makefile.objs qemu/hw/Makefile.objs >/dev/null 2>&1
then
    cp qemu_patch/Makefile.objs qemu/hw/Makefile.objs
fi
cp qemu_patch/fss qemu/hw -r
cp fli/fss_common.* qemu/hw/fss
cp qemu_patch/versatilepb.c qemu/hw/arm
cd qemu/
./configure --target-list=arm-softmmu --disable-user --enable-sdl --python=python2
patch -l -p2 < ../qemu_perl.patch
make -j 8
mkdir -p ../bin
cp arm-softmmu/qemu-system-arm ../bin/qemu_A

# Change the port number for B's QEmu and recompile
sed -i 's/4441/4442/g' hw/fss/fss.c
make -j 8
cp arm-softmmu/qemu-system-arm ../bin/qemu_B
cd ..
