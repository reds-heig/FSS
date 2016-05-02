#!/bin/bash

## FSS Reptar demo - build script                                ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

QUESTA_INCLUDE_PATH=/opt/EDA/mentor/questasim/10.2/questasim/include
cd ../include
gcc -c -fpic -I $QUESTA_INCLUDE_PATH `gdsl-config --flags` \
    cJSON.c fss_utils_fli.c fss_qemu_common.c -Wall
cd ../fli
gcc -c -fpic -I $QUESTA_INCLUDE_PATH -I ../include \
    `gdsl-config --flags` fss_reptar_fli.c -Wall && \
    gcc -shared fss_reptar_fli.o \
    ../include/fss_utils_fli.o ../include/cJSON.o ../include/fss_qemu_common.o \
    -o ../fss.so -lpthread `gdsl-config --libs`
cd ../fli_gui
gcc -c -fpic -I $QUESTA_INCLUDE_PATH -I ../include `gdsl-config --flags` \
    fss_gui_qtemu.c fss_gui_fli.c -Wall && \
    gcc -shared fss_gui_qtemu.o fss_gui_fli.o \
    ../include/cJSON.o ../include/fss_utils_fli.o ../include/fss_qemu_common.o \
    -o ../fss_gui.so -lpthread `gdsl-config --libs`
cd ../scripts
