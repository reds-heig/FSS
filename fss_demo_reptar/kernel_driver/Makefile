## FSS Reptar demo                                               ##
##                                                               ##
## FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) ##
##  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  ##

obj-m	    	:= fss_driver.o

PWD		:= $(shell pwd)
KERNELDIR 	:= ../linux
WARN    	:= -W -Wall -Wstrict-prototypes -Wmissing-prototypes

all:
	$(MAKE) ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -C $(KERNELDIR) M=$(PWD) ${WARN}

clean:
	rm -rf *.o *~ core .depend .*.cmd *.ko *.mod.c .tmp_versions modules.order Module.symvers module
