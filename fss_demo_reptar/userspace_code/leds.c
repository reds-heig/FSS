/*****************************************************************
 * leds - Userspace code for LED manipulation                    *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdint.h>

/* The command to send is a 1 followed by 8 bits, each corresponding to a led
   command */
/* Turn all leds off */
#define LEDS_OFF 0x100
/* Turn leds on on an alternate pattern */
#define LEDS_ON  0x1AA

int main(void)
{
    int fd;
char buf;

    uint16_t tmp = LEDS_OFF;

    fd = open("/dev/fss", O_RDWR);
    if (fd < 0) {
	perror("open:");
	return -1;
    }
    while (1) {
	/* When read unblocks, we have received an interrupt! */
	read(fd, &buf, sizeof(char));
	/* Alternate between leds off and on */
	if (tmp == LEDS_OFF) {
	    tmp = LEDS_ON;
	} else {
	    tmp = LEDS_OFF;
	}
	write(fd, &tmp, sizeof(uint16_t));
    }

    close(fd);
    return 0;
}
