/*****************************************************************
 * fss_qemu_common - Definitions and macros shared with QEmu     *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#include <unistd.h>
#include <assert.h>
#include <errno.h>

#include "fss_qemu_common.h"

/**
 * read_command() - Read a command structure from a socket, taking care of
 *                  internal signals that could interrupt the system call
 *
 * @sock: socket from which data is acquired
 * @cmd : allocated command structure where the read command will be returned
 * Return: -1 on failure, 0 on success
 */
int read_command(const int sock, command * const cmd)
{
    char *buf = (char *)cmd;
    ssize_t rc;
    int len;

    assert(cmd != NULL);

    /* IMPORTANT: Here we need to have this strange way of reading data from the
                  socket. Indeed, a signal arrives right after the write and
		  kills the read before it actually reads anything, making the
		  whole system crash. With this structure in place, however,
		  everything seems to be fine. */
    len = sizeof(command);
    while (len != 0 && (rc = read(sock, buf, len)) != 0) {
	if (rc < 0) {
	    if (errno == EINTR)
		continue;
	    ERR("*** Error while reading from socket ***\n");
	    return -1;
	}
	len -= rc;
	buf += rc;
    }
    if (len > 0) {
	/* When the simulation is stopped and the QEmu terminals are closed,
	   the function might still be called by the socket monitor, and the
	   above loop is simply skipped (read() will return 0, leaving the loop
	   immediately). This is a HUGE problem, as most likely the past command
	   is still in memory, so the socket monitor thinks it has been read and
	   pushes it into the queue, making the whole system go out of memory!
	   On the other hand, if the loop is skipped, len will be equal to
	   sizeof(command), so we can this event occurrence here. Simply
	   checking that its value is bigger than 0 should protect us from other
	   unplanned events. */
	return -1;
    }

    return 0;
}
