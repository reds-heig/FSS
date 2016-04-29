/**
 * fss_common - Definitions and macros shared with QEmu
 *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH)
 * Alberto Dassatti, Anthony Convers, Roberto Rigamonti, Xavier Ruppen -- 11.2015
 */

#ifndef FSS_UART_FLI_
#define FSS_UART_FLI_

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

#include "fss_common.h"

#define A_PORT	          4441          /* Port used for the A-endpoint */
#define B_PORT	          4442          /* Port used for the B-endpoint */

#define ADDR_BUS_SIZE     3
#define DATA_BUS_SIZE     8

/**
 * enum port_state - Port FSM's state
 */
typedef enum {
    IDLE = 0,
    DATA_WRITTEN,
    TRANSFER_END,
} port_state;

/**
 * Strings used for visualizing operations in FSM
 */
const char *op_strings[] = { "NOP",
			     "READ_OP",
			     "WRITE_OP",
			     "IRQ_OP" };

/**
 * struct sim_data - Instance information structure
 *
 * @srv_sock     : socket on which server will be listening for both DATA and
 *                 ISR connections
 * @cli_data_sock: socket for accepted DATA connection
 * @cli_isr_sock : socket for accepted ISR connection
 * @port         : port number for the communication
 * @endpoint     : which endpoint we are on (either A or B)
 * @p_state      : port FSM's state
 * @cnt          : counter used to match the frequency of the serial interface
 * @proc_queue   : queue of operations to process
 * @wr_lock      : mutex managing the access to the processing queue
 * @cmd          : command to execute
 */
typedef struct {
    /*** Signals ***/
    /* FLI -> VHDL model */
    mtiDriverIdT rst;      /* Reset button (active high) */
    mtiDriverIdT addr;
    mtiDriverIdT data_in;
    mtiDriverIdT wr;
    mtiDriverIdT rd;
    /* VHDL model -> FLI */
    mtiSignalIdT clk;      /* System clock (evolves at 100MHz) */
    mtiSignalIdT data_out;
    mtiSignalIdT irq;
    /* Constant */
    mtiDriverIdT cs;       /* Chip Select -> set to 1 */
    mtiDriverIdT baudce;   /* Baud Rate Generator Clock Enable -> set to 1 */
    /* Ignored */
    mtiSignalIdT ddis;
    mtiSignalIdT out1N;
    mtiSignalIdT out2N;
    mtiDriverIdT riN;

    /*** Internals ***/
    int srv_sock;
    int cli_data_sock;
    int cli_isr_sock;
    int port;
    char endpoint;
    port_state p_state;
    gdsl_queue_t proc_queue;
    pthread_mutex_t wr_lock;
    command *cmd;
} sim_data;

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

#endif /* FSS_UART_FLI_ */
