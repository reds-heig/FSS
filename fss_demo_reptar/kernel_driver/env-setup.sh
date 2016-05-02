#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

PP=../bin/toolchain

if [ -d "$PP" ] && [[ ":$PATH:" != *":$PP:"* ]]; then
    echo -n "Setting up environment variables..."
    PATH="${PATH:+"$PATH:"}$PP"
    echo "done."
fi
