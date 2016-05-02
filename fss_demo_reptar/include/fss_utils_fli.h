/*****************************************************************
 * fss_utils_fli - Common definitions and macros                 *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#ifndef FSS_UTILS_FLI_
#define FSS_UTILS_FLI_

#include <assert.h>
#include <math.h>
#include <fcntl.h>
#include <ctype.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/tcp.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/param.h>
#include <sys/queue.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <pthread.h>
#include <errno.h>

#include <gdsl.h>
#include <mti.h>

#include "fss_qemu_common.h"

/* Encoding of values used by Questasim */
typedef enum {
    STD_LOGIC_U,
    STD_LOGIC_X,
    STD_LOGIC_0,
    STD_LOGIC_1,
    STD_LOGIC_Z,
    STD_LOGIC_W,
    STD_LOGIC_L,
    STD_LOGIC_H,
    STD_LOGIC_D
} StdLogicType;

/**
 * FIND_PORT() - Find a port in HDL design, performing error checking
 *
 * @VAR_NAME  [mtiSignalIdT       ]: mtiSignalIdT variable linked to the signal
 *                                   from the found port
 * @PORT_NAME [char *             ]: name of the port in the HDL design
 * @PORT_LIST [mtiInterfaceListT *]: port list exported to the foreign interface
 */
#define FIND_PORT(VAR_NAME, PORT_NAME, PORT_LIST)			\
do {								        \
    VAR_NAME = mti_FindPort(PORT_LIST, PORT_NAME);			\
    if (VAR_NAME == NULL) {						\
	mti_PrintFormatted("*** Cannot find port %s ***\n", PORT_NAME); \
	mti_FatalError();						\
    }									\
} while (0);

/**
 * CREATE_DRIVER() - Create the driver of a given signal, performing error
 *                   checking
 *
 * @VAR_NAME  [mtiDriverIdT]: mtiDriverIdT variable that will be used to drive
 *                            the signal
 * @SIGNAL_ID [mtiSignalIdT]: variable holding the signal's ID
 */
#define CREATE_DRIVER(VAR_NAME, SIGNAL_ID)				\
do {								        \
    VAR_NAME = mti_CreateDriver(SIGNAL_ID);				\
    if (VAR_NAME == NULL) {						\
	mti_PrintMessage("*** Cannot create signal driver ***\n");	\
	mti_FatalError();						\
    }									\
} while (0);

/**
 * CREATE_PROCESS() - Create a process in Questasim, performing error checking
 *
 * @PROC_HANDLE [mtiProcessIdT   ]: handle of the created process
 * @PROC_NAME   [char *          ]: name given to the new process
 * @FUNC_PTR    [void (*)(void *)]: function executed in the process
 * @PARAMS      [void *          ]: parameter passed to the process
 */
#define CREATE_PROCESS(PROC_HANDLE, PROC_NAME, FUNC_PTR, PARAMS)        \
do {								        \
    PROC_HANDLE = mti_CreateProcess(PROC_NAME, FUNC_PTR, PARAMS);	\
    if (PROC_HANDLE == NULL) {						\
	mti_PrintMessage("*** Cannot create process ***\n");		\
	mti_FatalError();						\
    }									\
} while (0);

/**
 * SET_NONBLOCK_FLAG() - Set the non-blocking flag to a socket, performing error
 *                       checking
 *
 * @SOCKET [int]: socket descriptor
 */
#define SET_NONBLOCK_FLAG(SOCKET)					\
do {								        \
    if ((flags = fcntl(SOCKET, F_GETFL)) == -1) {			\
	mti_PrintMessage("*** fcntl-get error ***\n");			\
	perror("fcntl-get");						\
    } else {								\
	if (fcntl(SOCKET, F_SETFL,  flags | O_NONBLOCK) == -1) {	\
	    mti_PrintMessage("*** fcntl-set error ***\n");		\
	    perror("fcntl-set");					\
	}								\
    }									\
} while (0);

char convert_logic_vector_to_char(mtiSignalIdT vec);
void convert_char_to_logic_vector(char c,
				  const size_t n,
				  char * const logic_vector);

int convert_logic_vector_to_int(mtiSignalIdT vec);
void convert_int_to_logic_vector(int c,
				 const size_t n,
				 char * const logic_vector);

gdsl_element_t alloc_cmd(void *cmd);
void free_cmd(gdsl_element_t e);

#endif /* FSS_UTILS_FLI_ */
