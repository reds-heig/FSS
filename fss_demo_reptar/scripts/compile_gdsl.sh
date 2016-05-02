#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

# If never run configure before, then do it
cd ../libs/gdsl-1.8/
if [ ! -e "Makefile" ]; then
    ./configure
    make
    sudo make install
    sudo ldconfig
fi
cd ../../scripts
