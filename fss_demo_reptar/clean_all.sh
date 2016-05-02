#!/bin/bash

## FSS Reptar demo - cleanup script                              ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

rm fs_overlay_dir -rf
rm bin -rf
rm buildroot/output/target/fss_driver.ko -f
rm buildroot/output/target/leds -f
rm buildroot/output/images -rf
cd fli
rm *.o -f
cd ..
cd fli_gui
rm *.o -f
cd ..
cd include
rm *.o -f
cd ..
cd kernel_driver
rm *.o *.symvers *.order *.ko *.mod.c -f
cd ..
cd qtemu
make clean
cd ..
rm work -rf
rm *.so -f
rm transcript -f
rm *.wlf -f
rm *.vstf -f
