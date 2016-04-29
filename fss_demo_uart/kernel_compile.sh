#!/bin/bash
# FSS serial port demo - build script
#
# FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH)
# Alberto Dassatti, Anthony Convers, Roberto Rigamonti, Xavier Ruppen -- 11.2015

LINARO=gcc-linaro-5.1-2015.08-x86_64_arm-linux-gnueabihf
KERNEL=linux-4.1.4

if [ ! -e ${LINARO} ]; then
    wget https://releases.linaro.org/components/toolchain/binaries/latest-5.1/arm-linux-gnueabihf/${LINARO}.tar.xz
    tar xvf ${LINARO}.tar.xz
fi

if [[ ! "$PATH" =~ (^|:)"${LINARO}"(:|$) ]]; then
    export PATH=${LINARO}:$PATH
fi

if [ ! -e ${KERNEL} ]; then
    wget https://www.kernel.org/pub/linux/kernel/v4.x/${KERNEL}.tar.xz
    tar xvf ${KERNEL}.tar.xz
    ln -s ${KERNEL} linux
fi

cp kernelDOTconfig linux/.config
cp kernel_patch/core.c linux/arch/arm/mach-versatile/
cp kernel_patch/platform.h linux/arch/arm/mach-versatile/include/mach

cd linux/

make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- zImage
mkdir -p ../bin
cp arch/arm/boot/zImage ../bin/
cd ..
