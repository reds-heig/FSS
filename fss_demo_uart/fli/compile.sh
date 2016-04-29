#!/bin/bash
# FSS serial port demo - build script
#
# FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH)
# Alberto Dassatti, Anthony Convers, Roberto Rigamonti, Xavier Ruppen -- 11.2015

QUESTA_INCLUDE_PATH=/opt/EDA/mentor/questasim/10.2/questasim/include

gcc -c -fpic -I  $QUESTA_INCLUDE_PATH \
    `gdsl-config --flags` fss_common.c fss_uart_fli.c -Wall && gcc -shared  \
    fss_uart_fli.o fss_common.o -o ../A_fss.so -lpthread `gdsl-config --libs`
cp ../A_fss.so ../B_fss.so
