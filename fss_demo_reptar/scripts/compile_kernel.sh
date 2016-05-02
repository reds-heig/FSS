#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

cd ..
if [ ! -e "buildroot/output/build/linux-4.1.4/arch/arm/mach-versatile/core.c" ]
then
    echo "You have to compile buildroot's kernel before compiling this module!"
    exit
fi

if [ ! -e "linux" ]
then
    ln -s buildroot/output/build/linux-4.1.4 linux
fi

cp kernel_patch/core.c linux/arch/arm/mach-versatile/
cp kernel_patch/platform.h linux/arch/arm/mach-versatile/include/mach

rm buildroot/output/target/fss_driver.ko -f
rm buildroot/output/target/leds -f

cd buildroot/
make
cd ..
mkdir -p bin
cp buildroot/output/images/zImage bin/
cd scripts
