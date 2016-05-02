#!/bin/sh

## FSS Reptar demo - startup script                              ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

bin/qtemu &
vsim -64 -do sim_start.do -i &
