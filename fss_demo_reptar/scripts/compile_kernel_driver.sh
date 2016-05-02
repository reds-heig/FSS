#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

rm ../buildroot/output/target/fss_driver.ko -f
cd ../kernel_driver
./env-setup.sh
make
mkdir -p ../fs_overlay_dir
cp fss_driver.ko ../fs_overlay_dir
cd ..
