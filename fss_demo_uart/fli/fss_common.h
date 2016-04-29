/**
 * fss_common - Definitions and macros shared with QEmu
 *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH)
 * Alberto Dassatti, Anthony Convers, Roberto Rigamonti, Xavier Ruppen -- 11.2015
 */

#ifndef FSS_COMMON_H_
#define FSS_COMMON_H_

#include <stdio.h>

#define DEBUG		  0             /* Activate/deactivate debug messages */

/**
 * enum operations - Commands that can be executed
 */
typedef enum {
    NOP = 0,
    READ_OP,
    WRITE_OP,
    IRQ_OP,
} operations;

/**
 * enum irq_op - IRQ operation (raise or lower)
 */
typedef enum {
    IRQ_LOWER = 0,
    IRQ_RAISE,
} irq_op;

/**
 * struct command - Command received from/sent to the serial port
 *
 * @opcode: operation's opcode
 * @offset: memory address
 * @value : value to write (in a write operation)
 * @size  : write size
 */
typedef struct {
    int  opcode;
    char offset;
    char value;
    int  size;
} command;

/* Print error messages */
#define ERR(fmt, args...) fprintf(stderr, fmt, ## args)

/* If debug enabled, print debug messages */
#if DEBUG
#define DBG(fmt, args...) fprintf(stderr, fmt, ## args)
#else
#define DBG(fmt, args...)
#endif

int read_command(const int sock, command * const cmd);

#endif /* FSS_COMMON_H_ */
