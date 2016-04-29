/**
 * fss_common - Definitions and macros shared with QEmu
 *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH)
 * Alberto Dassatti, Anthony Convers, Roberto Rigamonti, Xavier Ruppen -- 11.2015
 */

#include "fss_uart_fli.h"

/* Flag set to 1 when termination is requested */
int quit_flag;

/**
 * alloc_cmd() - Allocate a command entry
 *
 * @cmd: element to allocate
 *
 * Return: Created entry, which is a deep copy of the one passed as argument,
 *         or NULL in case of malloc() failure
 */
gdsl_element_t alloc_cmd(void *cmd)
{
    command *c = (command *)cmd;
    command *ret = (command *)malloc(sizeof(command));

    assert(cmd != NULL);
    assert(ret != NULL);

    memcpy(ret, c, sizeof(command));

    return (gdsl_element_t)ret;
}

/**
 * free_cmd() - Free the memory associated to a command entry
 *
 * @e: element to free
 */
void free_cmd(gdsl_element_t e)
{
    free(e);
}

/**
 * configure_signals() - Configure the FLI signals and drivers
 *
 * @sim  : simulation's parameters
 * @ports: linked list of ports
 */
void configure_signals(sim_data * const sim,
		       mtiInterfaceListT *ports)
{
    mtiSignalIdT tmp; /* Temporary signal used to assign signals before
			 driving them */

    DBG("[%c - %s] Configure signals\n", sim->endpoint, __FUNCTION__);

    /** FLI -> VHDL model **/
    /* rst_o */
    FIND_PORT(tmp, "rst_o", ports);
    CREATE_DRIVER(sim->rst, tmp);
    /* addr_o */
    FIND_PORT(tmp, "addr_o", ports);
    CREATE_DRIVER(sim->addr, tmp);
    /* data_in_o */
    FIND_PORT(tmp, "data_in_o", ports);
    CREATE_DRIVER(sim->data_in, tmp);
    /* wr_o */
    FIND_PORT(tmp, "wr_o", ports);
    CREATE_DRIVER(sim->wr, tmp);
    /* rd_o */
    FIND_PORT(tmp, "rd_o", ports);
    CREATE_DRIVER(sim->rd, tmp);

    /** VHDL model -> FLI **/
    /* clk_i */
    FIND_PORT(sim->clk, "clk_i", ports);
    /* data_out_i */
    FIND_PORT(sim->data_out, "data_out_i", ports);
    /* irq_i */
    FIND_PORT(sim->irq, "irq_i", ports);

    /** Constant **/
    /* cs_o */
    FIND_PORT(tmp, "cs_o", ports);
    CREATE_DRIVER(sim->cs, tmp);
    /* baudce_o */
    FIND_PORT(tmp, "baudce_o", ports);
    CREATE_DRIVER(sim->baudce, tmp);

    /** Ignored **/
    /* ddis_i */
    FIND_PORT(sim->ddis, "ddis_i", ports);
    /* out1N_i */
    FIND_PORT(sim->out1N, "out1N_i", ports);
    /* out2N_i */
    FIND_PORT(sim->out2N, "out2N_i", ports);
    /* riN_o */
    FIND_PORT(tmp, "riN_o", ports);
    CREATE_DRIVER(sim->riN, tmp);
}

/**
 * close_sockets() - Close simulation's sockets
 *
 * @sim  : pointer to instance information structure
 */
void close_sockets(sim_data *sim)
{
    DBG("[%c - %s] Closing sockets\n", sim->endpoint, __FUNCTION__);

    close(sim->cli_data_sock);
    close(sim->cli_isr_sock);
}

/**
 * convert_logic_vector_to_char() - Convert a multibit signal into the
 *                                  corresponding numerical value
 *
 * @vec: std_logic_vector signal to convert
 *
 * Return: 8-bit char equivalent to the input signal
 */
char convert_logic_vector_to_char(mtiSignalIdT vec)
{
    mtiSignalIdT *elems_list;
    mtiTypeIdT sig_type;
    mtiInt32T num_elems;
    char data;
    int i;

    /* Get an handle to the type of the given signal */
    sig_type = mti_GetSignalType(vec);
    /* Get the number of elements that compose the vector */
    num_elems = mti_TickLength(sig_type);

    assert(num_elems <= 8);

    /* Extract the list of individual elements */
    elems_list = mti_GetSignalSubelements(vec, 0);

    data = 0;
    for (i = 0; i < num_elems; ++i) {
	/* If a 1 is received, increment the corresponding bit of the
	   result */
	if (mti_GetSignalValue(elems_list[i]) == STD_LOGIC_1) {
	    data += 1 << (num_elems - i - 1);
	}
    }

    mti_VsimFree(elems_list);
    return data;
}

/**
 * convert_char_to_logic_vector() - Convert a char value, with at most 8
 *                                  significant bits, into its binary
 *                                  representation over a character array
 *
 * @c           : char value to convert
 * @n           : number of bits to consider (values in [1, 8])
 * @logic_vector: vector that will hold the corresponding binary representation
 *
 * @note: The given binary representation is not composed by 0s and 1s, but by
 *        STD_LOGIC_0s and STD_LOGIC_1s
 */
void convert_char_to_logic_vector(char c,
				  const size_t n,
				  char * const logic_vector)
{
    int i;

    assert(n >= 1 && n <= 8);

    /* Progressively shift the value to convert, and select logic 1s and 0s
       accordingly */
    for (i = n-1; i >= 0; --i) {
	logic_vector[i] = (c & 1) && (i <= n - 1) ? STD_LOGIC_1 : STD_LOGIC_0;
	c >>= 1;
    }
}

/**
 * initialize_signals() - Initialize the simulation's signals
 *
 * @sim: simulation's parameters
 */
void initialize_signals(const sim_data * const sim)
{
    char tmp_buf[8]; /* Temporary buffer used for char->binary conversion */

    DBG("*** [%c - %s] Initialize signals ***\n", sim->endpoint, __FUNCTION__);

    /* Fill the vector with STD_LOGIC_0s */
    convert_char_to_logic_vector(0, 8, tmp_buf);

    /* rst -- keep the reset active during the first 1000ns */
    mti_ScheduleDriver(sim->rst, STD_LOGIC_1, 0, MTI_INERTIAL);
    mti_ScheduleDriver(sim->rst, STD_LOGIC_0, 1000, MTI_INERTIAL);
    /* addr */
    mti_ScheduleDriver(sim->addr, (long)(tmp_buf), 0, MTI_INERTIAL);
    /* data_in */
    mti_ScheduleDriver(sim->data_in, (long)(tmp_buf), 0, MTI_INERTIAL);
    /* wr */
    mti_ScheduleDriver(sim->wr, STD_LOGIC_0, 0, MTI_INERTIAL);
    /* rd */
    mti_ScheduleDriver(sim->rd, STD_LOGIC_0, 0, MTI_INERTIAL);
    /* cs -- Chip Select will stay at 1 */
    mti_ScheduleDriver(sim->cs, STD_LOGIC_1, 0, MTI_INERTIAL);
    /* baudce -- Baud Rate Generator Clock Enable will stay at 1 */
    mti_ScheduleDriver(sim->baudce, STD_LOGIC_1, 0, MTI_INERTIAL);
    /* riN */
    mti_ScheduleDriver(sim->riN, STD_LOGIC_1, 0, MTI_INERTIAL);
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

    DBG("*** [%c - %s] Initialize sockets ***\n", sim->endpoint, __FUNCTION__);

    if ((sim->srv_sock = socket(AF_INET, SOCK_STREAM, 0)) == -1) {
	ERR("*** [%c - %s] Error encountered while opening socket ***\n",
	    sim->endpoint, __FUNCTION__);
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
	ERR("*** [%c - %s] bind() error ***\n", sim->endpoint, __FUNCTION__);
	perror("bind()");
	close_sockets(sim);
	return -1;
    }

    /* Mark socket as passive */
    if (listen(sim->srv_sock, 2) == -1) {
	ERR("*** [%c - %s] listen() error ***\n", sim->endpoint, __FUNCTION__);
	perror("listen()");
	close_sockets(sim);
	return -1;
    }

    /* Block until a client connects, then create a new DATA socket for it */
    if ((sim->cli_data_sock = accept(sim->srv_sock,
				     (struct sockaddr *)&data_addr,
				     (socklen_t *)&addr_len)) == -1) {
	ERR("*** [%c - %s] DATA accept() error ***\n",
	    sim->endpoint, __FUNCTION__);
	perror("socket()");
	close(sim->srv_sock);
	return -1;
    }
    DBG("[%c - %s] Accepted new client DATA connection from host %s, port %d\n",
	sim->endpoint, __FUNCTION__,
	inet_ntoa(data_addr.sin_addr), ntohs(data_addr.sin_port));

    addr_len = sizeof(struct sockaddr_in);

    /* Block until a client connects, then create a new ISR socket for it */
    if ((sim->cli_isr_sock = accept(sim->srv_sock,
				    (struct sockaddr *)&isr_addr,
				    (socklen_t *)&addr_len)) == -1) {
	ERR("*** [%c - %s] ISR accept() error ***\n",
	    sim->endpoint, __FUNCTION__);
	perror("socket()");
	close(sim->srv_sock);
	close(sim->cli_data_sock);
	return -1;
    }
    DBG("[%c - %s] Accepted new client ISR connection from host %s, port %d\n",
	sim->endpoint, __FUNCTION__,
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

	DBG("[%c - %s] Received %s request, address: %#X, value: %#X\n",
	    sim->endpoint, __FUNCTION__,
	    op_strings[cmd.opcode], cmd.offset, cmd.value);

	/* On this socket we're just supposed to receive R/W operations */
	assert(cmd.opcode == WRITE_OP || cmd.opcode == READ_OP);

	/* Lock the mutex, push the read command in the queue, and then unlock
	   the mutex */
	DBG("[%c - %s] Trying to lock mutex\n", sim->endpoint, __FUNCTION__);
	pthread_mutex_lock(&sim->wr_lock);
	DBG("[%c - %s] Mutex locked\n", sim->endpoint, __FUNCTION__);

	gdsl_queue_insert(sim->proc_queue, (void *)&cmd);

	pthread_mutex_unlock(&sim->wr_lock);
	DBG("[%c - %s] Mutex unlocked\n", sim->endpoint, __FUNCTION__);
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
		DBG("--- [FSS %c - %ld.%ld] ---\n", sim->endpoint, tv.tv_sec, tv.tv_usec);

		/* Retrieve operation to perform */
		DBG("[%c - %s - FSM: IDLE] Trying to lock mutex\n",
		    sim->endpoint, __FUNCTION__);
		pthread_mutex_lock(&sim->wr_lock);
		DBG("[%c - %s - FSM: IDLE] Mutex locked\n",
		    sim->endpoint, __FUNCTION__);

		/* Extract the operation */
		sim->cmd = (command *)gdsl_queue_remove(sim->proc_queue);

		pthread_mutex_unlock(&sim->wr_lock);
		DBG("[%c - %s - FSM: IDLE] Mutex unlocked\n",
		    sim->endpoint, __FUNCTION__);

		assert(sim->cmd->opcode == READ_OP ||
		       sim->cmd->opcode == WRITE_OP);

		DBG("[%c - %s - FSM: IDLE] FSM started, %s at addr %#X\n",
		    sim->endpoint, __FUNCTION__,
		    op_strings[sim->cmd->opcode], sim->cmd->offset);

		/* Write desired address on address bus */
		convert_char_to_logic_vector(sim->cmd->offset, ADDR_BUS_SIZE,
					     addr_buf);
		mti_ScheduleDriver(sim->addr, (long)(addr_buf),
				   0, MTI_INERTIAL);

		if (sim->cmd->opcode == WRITE_OP) {
		    /* Write desired value on data bus */
		    char data_buf[DATA_BUS_SIZE];

		    DBG("[%c - %s - FSM: IDLE] Written value: %#X\n",
			sim->endpoint, __FUNCTION__, sim->cmd->value);

		    convert_char_to_logic_vector(sim->cmd->value, DATA_BUS_SIZE,
						 data_buf);
		    mti_ScheduleDriver(sim->data_in, (long)(data_buf),
				       0, MTI_INERTIAL);
		}

		sim->p_state = DATA_WRITTEN;
	    }
	    break;
	case DATA_WRITTEN:
	    DBG("[%c - %s - FSM: DATA_WRITTEN] \n", sim->endpoint, __FUNCTION__);
	    switch (sim->cmd->opcode) {
	    case READ_OP:
		DBG("[%c - %s - FSM: DATA_WRITTEN] setting RD signal\n",
		    sim->endpoint, __FUNCTION__);

		mti_ScheduleDriver(sim->rd, STD_LOGIC_1, 0, MTI_INERTIAL);
		break;
	    case WRITE_OP:
		DBG("[%c - %s] FSM WRITE done, setting WR signal\n",
		    sim->endpoint, __FUNCTION__);

		mti_ScheduleDriver(sim->wr, STD_LOGIC_1, 0, MTI_INERTIAL);
		break;
	    }
	    sim->p_state = TRANSFER_END;
	    break;
	case TRANSFER_END:
		switch (sim->cmd->opcode) {
		case READ_OP:
		    {
			command answer;
			/* Send back the answer to the reader */
			answer.opcode = NOP;
			answer.value =
			    convert_logic_vector_to_char(sim->data_out);
			answer.offset = 0;
			answer.size = 1;
			if (write(sim->cli_data_sock,
				  &answer, sizeof(command)) != sizeof(command)) {
			    ERR("*** [%c - %s - FSM: TRANSFER_END] ERROR on " \
				"DATA socket write -- SIMULATION STOPPED ***\n",
				sim->endpoint, __FUNCTION__);
			    mti_Quit();
			}
			/* Take down RD signal */
			mti_ScheduleDriver(sim->rd, STD_LOGIC_0,
					   0, MTI_INERTIAL);
		    }
		    break;
		case WRITE_OP:
		    /* Take down WR signal */
		    mti_ScheduleDriver(sim->wr, STD_LOGIC_0, 0, MTI_INERTIAL);
		    break;
		}

		DBG("[%c - %s - FSM: TRANSFER_END] Transfer end, returning " \
		    "to IDLE\n", sim->endpoint, __FUNCTION__);

		sim->p_state = IDLE;
		free_cmd(sim->cmd);
		break;
	default:
	    ERR("*** [%c - %s - FSM: INVALID] Invalid FSM state ***\n",
		sim->endpoint, __FUNCTION__);
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

    cmd.opcode = IRQ_OP;
    cmd.value =
	mti_GetSignalValue(sim->irq) == STD_LOGIC_1 ? IRQ_RAISE : IRQ_LOWER;

    if (write(sim->cli_isr_sock, &cmd, sizeof(command)) != sizeof(command)) {
	ERR("*** [%c - %s] ERROR on ISR socket write ***\n",
	    sim->endpoint, __FUNCTION__);
    }

    if (cmd.value == IRQ_RAISE) {
	DBG("[%c - %s] IRQ received\n", sim->endpoint, __FUNCTION__);
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

    DBG("[%c - %s] Simulation END\n", sim->endpoint, __FUNCTION__);

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

    DBG("[%c - %s] Simulation RESTART\n", sim->endpoint, __FUNCTION__);
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
    pthread_t sock_mon;

    /* Allocate memory for ports -- no need to check if valid, FLI does
       it for us */
    sim = (sim_data *)mti_Malloc(sizeof(sim_data));

    /* Initialize FSM */
    sim->p_state = IDLE;

    /* Initialize queue */
    sim->proc_queue = gdsl_queue_alloc("ProcessingQ", alloc_cmd, free_cmd);

    /* Get the FLI call parameter */
    sim->endpoint = toupper(param[0]);
    DBG("** [%c - %s] STARTED **\n", sim->endpoint, __FUNCTION__);

    /* Select the port according to which endpoint we're considering */
    sim->port = (sim->endpoint == 'A' ? A_PORT : B_PORT);

    /* Set the program as running */
    quit_flag = 0;

    /* Configure the FLI signals and drivers*/
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
	ERR("*** [%c - %s] Failed to initialize sockets ***\n",
	    sim->endpoint, __FUNCTION__);
	mti_FatalError();
    }

    /* Start monitoring the socket for incoming messages */
    pthread_create(&sock_mon, NULL, socket_monitor, (void *)sim);

    /* Set callbacks */
    mti_AddQuitCB(quit_callback, sim);
    mti_AddRestartCB(restart_callback, sim);
}
