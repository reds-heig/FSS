/*****************************************************************
 * fss_reptar_fli - Interface between QEMU and QuestaSim         *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#include "fss_reptar_fli.h"

/* Flag set to 1 when termination is requested */
int quit_flag;

/**
 * configure_signals() - Configure the FLI signals and drivers
 *
 * @sim  : simulation's parameters
 * @ports: linked list of ports
 */
void configure_signals(sim_data * const sim,
		       mtiInterfaceListT *ports)
{
    DBG("[%s] Configure signals\n",  __FUNCTION__);

    /* Connect signals */
    FIND_PORT(sim->clk, "clk_i", ports);
    FIND_PORT(sim->rst, "rst_i", ports);
    FIND_PORT(sim->irq, "irq_received_i", ports);
    FIND_PORT(sim->read_data, "data_read_i", ports);
    FIND_PORT(sim->datavalid_read, "datavalid_read_i", ports);

    FIND_PORT(sim->wr, "wr_o", ports);
    FIND_PORT(sim->rd, "rd_o", ports);
    FIND_PORT(sim->write_addr, "write_addr_o", ports);
    FIND_PORT(sim->read_addr, "read_addr_o", ports);
    FIND_PORT(sim->write_data, "write_data_o", ports);

    /* Create signal drivers */
    CREATE_DRIVER(sim->wr_drv, sim->wr);
    CREATE_DRIVER(sim->rd_drv, sim->rd);
    CREATE_DRIVER(sim->write_addr_drv, sim->write_addr);
    CREATE_DRIVER(sim->read_addr_drv, sim->read_addr);
    CREATE_DRIVER(sim->write_data_drv, sim->write_data);
}

/**
 * close_sockets() - Close simulation's sockets
 *
 * @sim  : pointer to instance information structure
 */
void close_sockets(sim_data *sim)
{
    DBG("[%s] Closing sockets\n",  __FUNCTION__);

    close(sim->cli_data_sock);
    close(sim->cli_isr_sock);
}

#define NS_EXPONENT -9
/**
 * convertToNS() - Convert current simulator resolution into nanoseconds
 *
 * Note: code taken from Mentor's FLI documentation.
 *
 * @delay: value to convert into nanoseconds
 *
 * Return: Desired delay value in the current simulator resolution
 */
mtiDelayT convertToNS(mtiDelayT delay)
{
    int exp = NS_EXPONENT - mti_GetResolutionLimit();

    if (exp < 0) {
	/* Simulator resolution limit is coarser than ns. */
	/* Cannot represent delay accurately, so truncate it. */
	while (exp++) {
	    delay /= 10;
	}
    } else {
	/* Simulator resolution limit is finer than ns. */
	while (exp--) {
	    delay *= 10;
	}
    }
    return delay;
}

/**
 * initialize_signals() - Initialize the simulation's signals
 *
 * Signals (wr, rd, the addresses, and the data bus) are at first reset.
 * Then, interrupts linked with the buttons are enabled by writing 0x80 in the
 * register at address 0xC.
 *
 * @sim: simulation's parameters
 */
void initialize_signals(const sim_data * const sim)
{
    DBG("*** [%s] Initialize signals ***\n", __FUNCTION__);

    /*
      Since we are not running the simulation yet, we have no notion of time
      here. Therefore, if we are planning some operations, we cannot simply
      drive the signal as we wish, but rather *force* them (in particular,
      with the DEPOSIT option, so that they can be overwritten without harm).
    */
    mti_ForceSignal(sim->wr, "0", 0, MTI_FORCE_DEPOSIT, -1, -1);
    mti_ForceSignal(sim->rd, "0", 0, MTI_FORCE_DEPOSIT, -1, -1);

    mti_ForceSignal(sim->read_addr, "25'h0000000", 0,
		    MTI_FORCE_DEPOSIT, -1, -1);
    mti_ForceSignal(sim->write_addr, "25'h0000000", 0,
		    MTI_FORCE_DEPOSIT, -1, -1);
    mti_ForceSignal(sim->write_data, "16'h0000", 0,
		    MTI_FORCE_DEPOSIT, -1, -1);

    mti_ForceSignal(sim->write_addr, "25'h000000C", convertToNS(2000),
		    MTI_FORCE_DEPOSIT, -1, -1);
    mti_ForceSignal(sim->write_data, "16'h0080", convertToNS(2000),
		    MTI_FORCE_DEPOSIT, -1, -1);
    mti_ForceSignal(sim->wr, "1", convertToNS(2000),
		    MTI_FORCE_DEPOSIT, -1, -1);
    mti_ForceSignal(sim->wr, "0", convertToNS(2200),
		    MTI_FORCE_DEPOSIT, -1, -1);
}

/**
 * init_sockets() - Initialize sockets. The first connections is the DATA one,
 *                  whereas the second connection (on the same port!) is the ISR
 *                  one
 *
 * @sim: pointer to instance information structure
 *
 * Return: 0 if sockets successfully initialized, -1 otherwise
 */
int init_sockets(sim_data * const sim)
{
    int addr_len = sizeof(struct sockaddr_in);
    struct sockaddr_in server_addr;
    struct sockaddr_in data_addr;
    struct sockaddr_in isr_addr;

    DBG("*** [%s] Initialize sockets ***\n",  __FUNCTION__);

    if ((sim->srv_sock = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
	ERR("*** [%s] Error encountered while opening socket ***\n",
	     __FUNCTION__);
	return -1;
    }

    /* Set address parameters */
    memset(&server_addr, 0, sizeof(server_addr));
    server_addr.sin_family = AF_INET;
    server_addr.sin_addr.s_addr = INADDR_ANY;
    server_addr.sin_port = htons(sim->port);

    /* Bind socket to the specified address */
    if (bind(sim->srv_sock, (struct sockaddr *)&server_addr,
	     sizeof(server_addr)) == -1) {
	ERR("*** [%s] bind() error ***\n",  __FUNCTION__);
	perror("bind()");
	close_sockets(sim);
	return -1;
    }

    /* Mark socket as passive */
    if (listen(sim->srv_sock, 2) == -1) {
	ERR("*** [%s] listen() error ***\n",  __FUNCTION__);
	perror("listen()");
	close_sockets(sim);
	return -1;
    }

    /* Block until a client connects, then create a new DATA socket for it */
    if ((sim->cli_data_sock = accept(sim->srv_sock,
				     (struct sockaddr *)&data_addr,
				     (socklen_t *)&addr_len)) == -1) {
	ERR("*** [%s] DATA accept() error ***\n",
	     __FUNCTION__);
	perror("socket()");
	close(sim->srv_sock);
	return -1;
    }
    DBG("[%s] Accepted new client DATA connection from host %s, port %d\n",
	 __FUNCTION__,
	inet_ntoa(data_addr.sin_addr), ntohs(data_addr.sin_port));

    addr_len = sizeof(struct sockaddr_in);

    /* Block until a client connects, then create a new ISR socket for it */
    if ((sim->cli_isr_sock = accept(sim->srv_sock,
    				    (struct sockaddr *)&isr_addr,
    				    (socklen_t *)&addr_len)) == -1) {
    	ERR("*** [%s] ISR accept() error ***\n",
    	     __FUNCTION__);
    	perror("socket()");
    	close(sim->srv_sock);
    	close(sim->cli_data_sock);
    	return -1;
    }
    DBG("[%s] Accepted new client ISR connection from host %s, port %d\n",
    	 __FUNCTION__,
    	inet_ntoa(isr_addr.sin_addr), ntohs(isr_addr.sin_port));

    /* The server socket can now be closed */
    close(sim->srv_sock);

    return 0;
}

/**
 * socket_monitor() - Thread that monitors the socket for incoming messages and
 *                    enqueues them
 *
 * @param: pointer to the instance information structure casted in a void type
 *
 * Return: this function should never return
 */
void *socket_monitor(void * const param)
{
    sim_data *sim = (sim_data * const)param;
    command cmd;

    while (1) {
	if (read_command(sim->cli_data_sock, &cmd) != 0 || quit_flag) {
	    return 0;
	}

	/* On this socket we're just supposed to receive R/W operations */
	assert(cmd.opcode == WRITE_OP || cmd.opcode == READ_OP);

	if (cmd.opcode == READ_OP) {
	    DBG("[%s] Received READ request, address: %#X\n",
		__FUNCTION__, cmd.offset);
	} else {
	    DBG("[%s] Received WRITE request, address: %#X, value: %#X\n",
		__FUNCTION__, cmd.offset, cmd.value);
	}

	/* Lock the mutex, push the read command in the queue, and then unlock
	   the mutex */
	DBG("[%s] Trying to lock mutex\n",  __FUNCTION__);
	pthread_mutex_lock(&sim->wr_lock);
	DBG("[%s] Mutex locked\n",  __FUNCTION__);

	gdsl_queue_insert(sim->proc_queue, (void *)&cmd);

	pthread_mutex_unlock(&sim->wr_lock);
	DBG("[%s] Mutex unlocked\n",  __FUNCTION__);
    }

    return 0;
}

/**
 * port_handler() - Perform a read or write operation on the serial port
 *
 * @param: pointer to the instance information structure casted in a void type
 */
void port_handler(void * const param)
{
    sim_data *sim = (sim_data *)param;

    if (mti_GetSignalValue(sim->clk) == STD_LOGIC_1) {
	switch (sim->p_state) {
	case IDLE:
	    /*
	      If the queue is not empty, we have a new operation to perform.
	      1 - access the queue (in a safe way) to get the operation
	      2 - start the FSM with the selected operation (data concerning
	          the operation has to be stored in the instance structure as
		  this function gets called at each beat of the simulated clock)
	     */
	    if (!gdsl_queue_is_empty(sim->proc_queue)) {
		char addr_buf[ADDR_BUS_SIZE];

		struct timeval tv;
		gettimeofday(&tv, NULL);
		DBG("--- [FSS - %ld.%ld] ---\n",  tv.tv_sec, tv.tv_usec);

		/* Retrieve operation to perform */
		DBG("[%s - FSM: IDLE] Trying to lock mutex\n",
		     __FUNCTION__);
		pthread_mutex_lock(&sim->wr_lock);
		DBG("[%s - FSM: IDLE] Mutex locked\n",
		     __FUNCTION__);

		/* Extract the operation */
		sim->cmd = (command *)gdsl_queue_remove(sim->proc_queue);

		pthread_mutex_unlock(&sim->wr_lock);
		DBG("[%s - FSM: IDLE] Mutex unlocked\n",
		     __FUNCTION__);

		assert(sim->cmd->opcode == READ_OP ||
		       sim->cmd->opcode == WRITE_OP);

		convert_int_to_logic_vector(sim->cmd->offset, ADDR_BUS_SIZE,
					    addr_buf);

		if (sim->cmd->opcode == READ_OP) {
		    DBG("[%s - FSM: IDLE] FSM started, READ at addr %#X\n",
			__FUNCTION__, sim->cmd->offset);

		    mti_ScheduleDriver(sim->read_addr_drv, (long)(addr_buf),
				       0, MTI_INERTIAL);
		    mti_ScheduleDriver(sim->rd_drv, STD_LOGIC_1,
				       0, MTI_INERTIAL);

		} else {
		    char data_buf[DATA_BUS_SIZE];

		    DBG("[%s - FSM: IDLE] FSM started, WRITE at addr %#X, " \
			"value %#X\n",
			__FUNCTION__, sim->cmd->offset, sim->cmd->value);

		    mti_ScheduleDriver(sim->write_addr_drv, (long)(addr_buf),
				       0, MTI_INERTIAL);

		    convert_int_to_logic_vector(sim->cmd->value, DATA_BUS_SIZE,
						data_buf);
		    mti_ScheduleDriver(sim->write_data_drv, (long)(data_buf),
				       0, MTI_INERTIAL);
		    mti_ScheduleDriver(sim->wr_drv, STD_LOGIC_1,
				       0, MTI_INERTIAL);
		}

		sim->p_state = DATA_WRITTEN;
	    }
	    sim->cnt = 0;
	    break;
	case DATA_WRITTEN:
	    if (sim->cnt++ == WAIT_DELAY) {
		DBG("[%s - FSM: DATA_WRITTEN] \n",  __FUNCTION__);
		switch (sim->cmd->opcode) {
		case READ_OP:
		    DBG("[%s - FSM: DATA_WRITTEN] setting RD signal\n",
			__FUNCTION__);

		    mti_ScheduleDriver(sim->rd_drv, STD_LOGIC_0, 0, MTI_INERTIAL);
		    break;
		case WRITE_OP:
		    DBG("[%s] FSM WRITE done, setting WR signal\n",
			__FUNCTION__);

		    mti_ScheduleDriver(sim->wr_drv, STD_LOGIC_0, 0, MTI_INERTIAL);
		    break;
		}
		sim->p_state = TRANSFER_END;
		sim->cnt = 0;
	    }
	    break;
	case TRANSFER_END:
	    if (sim->cnt == WAIT_DELAY) {
		if (sim->cmd->opcode == READ_OP) {
		    command answer;
		    /* Send back the answer to the reader */
		    answer.opcode = NOP;
		    answer.value =
			convert_logic_vector_to_int(sim->read_data);
		    answer.offset = 0;

		    DBG("\n###### READ VALUE: %#X ######\n\n", answer.value);

		    if (write(sim->cli_data_sock,
			      &answer, sizeof(command)) != sizeof(command)) {
			ERR("*** [%s - FSM: TRANSFER_END] ERROR on " \
			    "DATA socket write -- SIMULATION STOPPED ***\n",
			    __FUNCTION__);
			mti_Quit();
		    }
		}

		DBG("[%s - FSM: TRANSFER_END] Transfer end, returning " \
		    "to IDLE\n",  __FUNCTION__);

		sim->p_state = IDLE;
		free_cmd(sim->cmd);
	    } else {
		sim->cnt++;
	    }
	    break;
	default:
	    ERR("*** [%s - FSM: INVALID] Invalid FSM state ***\n",
		 __FUNCTION__);
	    mti_FatalError();
	    break;
	}
    }
}

/**
 * irq_handler() - Forward IRQs raised by the serial port to QEmu
 *
 * @param: pointer to the instance information structure casted in a void type
 */
void irq_handler(void * const param)
{
    sim_data *sim = (sim_data *)param;
    command cmd;

    if (mti_GetSignalValue(sim->irq) == STD_LOGIC_1) {
	cmd.opcode = IRQ_OP;
	cmd.value = IRQ_RAISE;

	if (write(sim->cli_isr_sock, &cmd, sizeof(command)) != sizeof(command)) {
	    ERR("*** [%s] ERROR on ISR socket write ***\n",
		__FUNCTION__);
	}

	DBG("[%s] IRQ received\n",  __FUNCTION__);
	/* Clear the IRQ */
	cmd.opcode = WRITE_OP;
	cmd.offset = 0xC;
	cmd.value = 0x81;

	pthread_mutex_lock(&sim->wr_lock);
	DBG("[%s] Mutex locked\n",  __FUNCTION__);

	gdsl_queue_insert(sim->proc_queue, (void *)&cmd);

	pthread_mutex_unlock(&sim->wr_lock);
	DBG("[%s] Mutex unlocked\n",  __FUNCTION__);
    } else {
	cmd.opcode = IRQ_OP;
	cmd.value = IRQ_LOWER;

	if (write(sim->cli_isr_sock, &cmd, sizeof(command)) != sizeof(command)) {
	    ERR("*** [%s] ERROR on ISR socket write ***\n",
		__FUNCTION__);
	}

	DBG("[%s] IRQ released\n",  __FUNCTION__);
    }
}

/**
 * quit_callback() - Callback invoked on quit
 *
 * @param: pointer to the instance information structure casted in a void type
 */
void quit_callback(void * const param)
{
    sim_data *sim = (sim_data *)param;

    DBG("[%s] Simulation END\n",  __FUNCTION__);

    quit_flag = 1;

    /* Free queue's memory */
    gdsl_queue_free(sim->proc_queue);

    /* Close sockets */
    close_sockets(sim);

    /* Free private data */
    mti_Free(sim);
}

/**
 * restart_callback() - Callback invoked on simulation's end or restart
 *
 * @param: pointer to the instance information structure casted in a void type
 */
void restart_callback(void * const param)
{
    sim_data *sim = (sim_data *)param;

    /* Re-initialize signals */
    initialize_signals(sim);

    /* Flush queue's memory */
    gdsl_queue_flush(sim->proc_queue);

    /* Reset FSM */
    sim->p_state = IDLE;

    DBG("[%s] Simulation RESTART\n",  __FUNCTION__);
}

/**
 * fss_init() - FLI initialization routine
 *
 * @region  : region in design for this instance
 * @param   : last part of the string in foreign attributes
 * @generics: linked list of generic values
 * @ports   : linked list of ports
 *
 * @TODO: Investigate quit-restart callbacks!
 */
void fss_init(mtiRegionIdT region,
	      char *param,
	      mtiInterfaceListT *generics,
	      mtiInterfaceListT *ports)
{
    sim_data *sim;              /* Simulation's parameters */
    mtiProcessIdT isr_proc;     /* ISR process handle */
    mtiProcessIdT port_proc;    /* Process handle for the thread that interacts
				   with the port */
    pthread_t sock_mon;         /* Handle for the thread that monitors the
				   socket for commands */

    /* Allocate memory for ports -- no need to check if valid, FLI does
       it for us */
    sim = (sim_data *)mti_Malloc(sizeof(sim_data));

    /* Initialize FSM */
    sim->p_state = IDLE;

    /* Initialize queue */
    sim->proc_queue = gdsl_queue_alloc("ProcessingQ", alloc_cmd, free_cmd);

    DBG("** [%s] STARTED **\n",  __FUNCTION__);
    sim->port = FLI_QEMU_PORT;

    /* Set the program as running */
    quit_flag = 0;

    /* Configure the FLI signals and drivers */
    configure_signals(sim, ports);

    /* Give all the output signals an initial value */
    initialize_signals(sim);

    /* Create the process that will handle interrupts */
    CREATE_PROCESS(isr_proc, "<FSS_isr_fli>", irq_handler, sim);
    /* Make ISR process sensitive to interrupts */
    mti_Sensitize(isr_proc, sim->irq, MTI_EVENT);

    /* Create the process that will handle the port interface */
    CREATE_PROCESS(port_proc, "<FSS_port_fli>", port_handler, sim);
    /* Make port handler process sensitive to the clock */
    mti_Sensitize(port_proc, sim->clk, MTI_EVENT);

    /* Open sockets */
    if (init_sockets(sim) == -1) {
	ERR("*** [%s] Failed to initialize sockets ***\n",
	     __FUNCTION__);
	mti_FatalError();
    }

    /* Start monitoring the socket for incoming messages */
    pthread_create(&sock_mon, NULL, socket_monitor, (void *)sim);

    /* Set callbacks */
    mti_AddQuitCB(quit_callback, sim);
    mti_AddRestartCB(restart_callback, sim);
}
