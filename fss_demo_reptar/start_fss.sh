#!/bin/sh

## FSS Reptar demo - startup script                              ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

bin/qemu_fss -M versatilepb -m 128M -nographic \
    -kernel buildroot/output/images/zImage \
    -initrd buildroot/output/images/rootfs.cpio \
    -append "root=/dev/ram0 rw console=ttyAMA0,115200"
