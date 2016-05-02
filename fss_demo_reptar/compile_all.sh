#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

./clean_all.sh
cp config/buildrootDOTconfig buildroot/.config
cd buildroot
make
cd ../scripts
./compile_fli.sh
./compile_qemu.sh
./compile_qtemu.sh
./compile_gdsl.sh
./compile_userspace_code.sh
./compile_kernel_driver.sh
./compile_kernel.sh
cd ..
# Re-run again to include the overlay
cd buildroot
make
cd ..
