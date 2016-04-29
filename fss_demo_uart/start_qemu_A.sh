#!/bin/bash
# FSS serial port demo - build script
#
# FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH)
# Alberto Dassatti, Anthony Convers, Roberto Rigamonti, Xavier Ruppen -- 11.2015

bin/qemu_A -M versatilepb -m 128M -nographic \
    -kernel bin/zImage -append "console=ttyAMA0,115200"
