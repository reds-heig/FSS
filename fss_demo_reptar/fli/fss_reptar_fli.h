/*****************************************************************
 * fss_reptar_fli - Interface between QEMU and QuestaSim         *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

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

#include "fss_utils_fli.h"
#include "fss_qemu_common.h"

#define ADDR_BUS_SIZE     25
#define DATA_BUS_SIZE     16

#define WAIT_DELAY        40

/**
 * enum port_state - Port FSM's state
 */
typedef enum {
    IDLE = 0,
    DATA_WRITTEN,
    TRANSFER_END,
} port_state;

/**
 * struct sim_data - Instance information structure
 *
 * @srv_sock     : socket on which server will be listening for both DATA and
 *                 ISR connections
 * @cli_data_sock: socket for accepted DATA connection
 * @cli_isr_sock : socket for accepted ISR connection
 * @port         : port number for the communication
 * @p_state      : port FSM's state
 * @proc_queue   : queue of operations to process
 * @wr_lock      : mutex managing the access to the processing queue
 * @cmd          : command to execute
 * @cnt          : counter used to time signal operations
 */
typedef struct {
    /* FPGA -> QEmu */
    mtiSignalIdT clk;
    mtiSignalIdT rst;      /* Reset button (active high) */
    mtiSignalIdT irq;
    mtiSignalIdT read_data;

    /* QEmu -> FPGA */
    mtiSignalIdT wr;
    mtiSignalIdT rd;
    mtiSignalIdT write_addr;
    mtiSignalIdT read_addr;
    mtiSignalIdT write_data;
    mtiSignalIdT datavalid_read;

    /*** Signal drivers ***/
    mtiDriverIdT wr_drv;
    mtiDriverIdT rd_drv;
    mtiDriverIdT write_addr_drv;
    mtiDriverIdT read_addr_drv;
    mtiDriverIdT write_data_drv;

    /*** Internals ***/
    int srv_sock;
    int cli_data_sock;
    int cli_isr_sock;
    int port;
    port_state p_state;
    gdsl_queue_t proc_queue;
    pthread_mutex_t wr_lock;
    command *cmd;
    int cnt;
} sim_data;

#endif /* FSS_REPTAR_FLI_ */
