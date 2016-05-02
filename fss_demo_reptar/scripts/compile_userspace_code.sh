#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

mkdir -p ../fs_overlay_dir
toolchain/arm-buildroot-linux-uclibcgnueabi-gcc ../userspace_code/leds.c \
    -o ../fs_overlay_dir/leds
