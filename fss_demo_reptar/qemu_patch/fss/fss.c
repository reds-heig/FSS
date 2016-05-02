/*****************************************************************
 * fss - Virtual device in QEmu                                  *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>

#include "hw/sysbus.h"
#include "qemu/sockets.h"
#include "qemu/thread.h"

#include "fss_qemu_common.h"

/* Dynamic conversion check for QEmu */
#define TYPE_FSS                  "fss"
#define FSS(obj)                  OBJECT_CHECK(FSSState, (obj), TYPE_FSS)

/* FLI TCP address */
#define FLI_HOST                  "127.0.0.1"
#define HOSTNAME_LENGTH           255

#define FSS_MMEMORY_SIZE          1024

/**
 * struct FSSState - State of the simulated object, along with its private data
 *
 * @parent_obj: parent virtual device
 * @data_sock : socket for data communication
 * @irq_sock  : socket for IRQ communication
 * @hostname  : FLI's hostname
 * @irq       : IRQ line
 * @irq_thread: handler for the thread that deals with the interrupts
 */
typedef struct FSSState {
    SysBusDevice parent_obj;

    MemoryRegion iomem;
    int data_sock;
    int irq_sock;
    char hostname[HOSTNAME_LENGTH];

    qemu_irq irq;
    QemuThread irq_thread;
} FSSState;

/**
 * fss_receive_interrupt() - Handle an interrupt received through the socket,
 *                           propagating it
 *
 * @opaque: opaque pointer to the private data
 *
 * Return: NULL
 */
static void *fss_receive_interrupt(void *opaque)
{
    FSSState *s = (FSSState *)opaque;
    command cmd;
    int rc;

    while (1) {
	/* Block in a read operation on the socket, waiting for an interrupt
	   message to arrive */
	rc = read(s->irq_sock, &cmd, sizeof(command));
	assert(rc >= 0);

	DBG("[FSS - %s] IRQ received\n", __FUNCTION__);
	qemu_irq_raise(s->irq);
	/* Wait for a while, then lower the IRQ signal */
	usleep(1000);
	qemu_irq_lower(s->irq);
    }

    return 0;
}

/**
 * fss_init_sockets() - Initialize sockets for communication with the FLI
 *
 * @s: pointer to private data
 *
 * Note: Connections are made one after the other at the same address:port pair.
 *       The assumption here is that the first connection is for the data, the
 *       second one for the interrupts.
 */
static void fss_init_sockets(FSSState *s)
{
    Error *local_err = NULL;

    snprintf(s->hostname, HOSTNAME_LENGTH, "%s:%d", FLI_HOST, FLI_QEMU_PORT);
    DBG("[FSS - %s] Creating DATA socket and connecting to %s\n",
	__FUNCTION__, s->hostname);
    s->data_sock = inet_connect(s->hostname, &local_err);
    if (s->data_sock < 0) {
	ERR("*** [FSS - %s] Error connecting to %s (DATA) **\n",
	    __FUNCTION__, s->hostname);
	exit(EXIT_FAILURE);
    }
    DBG("[FSS - %s] DATA - successfully connected to %s\n",
	__FUNCTION__, s->hostname);

    DBG("[FSS - %s] Creating IRQ socket and connecting to %s\n",
	__FUNCTION__, s->hostname);
    s->irq_sock = inet_connect(s->hostname, &local_err);
    if (s->irq_sock < 0) {
	ERR("*** [FSS - %s] Error connecting to %s (IRQ) **\n",
	    __FUNCTION__, s->hostname);
	exit(EXIT_FAILURE);
    }
    DBG("[FSS - %s] IRQ - successfully connected to %s\n",
	__FUNCTION__, s->hostname);
}

/**
 * fss_read() - Retrieve a value from FLI at the specified offset
 *
 * @opaque: opaque pointer to the private data
 * @offset: offset of the desired value
 * @size  : size of the value to read (in bytes)
 *
 * Return: Value read from the socket
 */
static uint64_t fss_read(void *opaque, hwaddr offset, unsigned size)
{
    FSSState *s = (FSSState *)opaque;

    command cmd;
    struct timeval tv;

    gettimeofday(&tv, NULL);
    DBG("[FSS - %s - %ld.%ld] Read request at offset %#X, size %d\n",
	__FUNCTION__, tv.tv_sec, tv.tv_usec, (unsigned int)offset >> 2, size);

    /* Send the read request, then wait for a response */
    cmd.opcode = READ_OP;
    cmd.offset = offset;

    if (write(s->data_sock, &cmd, sizeof(command)) != sizeof(command)) {
	ERR("*** [FSS - %s] Error encountered in socket write **\n",
	    __FUNCTION__);
	exit(0);
    }
    if (read_command(s->data_sock, &cmd) != 0) {
	exit(0);
    }

    DBG("[FSS - %s] Read value: %#X\n", __FUNCTION__, cmd.value);

    return (uint64_t)cmd.value;
}

/**
 * fss_write() - Write a given value to FLI at the specified offset
 *
 * @opaque: opaque pointer to the private data
 * @offset: offset of the desired value
 * @value : value to write
 * @size  : size of the value to write (in bytes)
 */
static void fss_write(void *opaque, hwaddr offset,
		      uint64_t value, unsigned size)
{
    FSSState *s = (FSSState *)opaque;

    command cmd;
    struct timeval tv;

    gettimeofday(&tv, NULL);
    DBG("[FSS - %s - %ld.%ld] Write request at offset %#X, size %d, value %#X\n",
	__FUNCTION__, tv.tv_sec, tv.tv_usec,
	(unsigned int)offset >> 1, size, (unsigned int)value);

    cmd.opcode = WRITE_OP;
    /* The offset is divided by two since we pass it from the kernel as a u16,
       while here we are addressing it as bytes */
    cmd.offset = offset >> 1;
    cmd.value = value;

    if (write(s->data_sock, &cmd, sizeof(command)) != sizeof(command)) {
	ERR("*** [FSS - %s] Error encountered in socket write **\n",
	    __FUNCTION__);
	exit(0);
    }
}

/* Handlers for memory operations */
static const MemoryRegionOps fss_ops = {
    .read       = fss_read,
    .write      = fss_write,
    .endianness = DEVICE_NATIVE_ENDIAN,
};

/**
 * fss_realize() - Device instantiation in QEmu
 *
 * @dev : pointer to private data
 * @errp: pointer to error message
 */
static void fss_realize(DeviceState *dev, Error **errp)
{
    FSSState *s = FSS(dev);

    sysbus_init_irq(SYS_BUS_DEVICE(dev), &s->irq);

    /* Initialize memory management */
    memory_region_init_io(&s->iomem, OBJECT(s), &fss_ops, s,
			  TYPE_FSS, FSS_MMEMORY_SIZE);
    sysbus_init_mmio(SYS_BUS_DEVICE(dev), &s->iomem);

    fss_init_sockets(s);

    /* Instantiate IRQ handler */
    qemu_thread_create(&s->irq_thread, "irq_thread", fss_receive_interrupt, s,
    		       QEMU_THREAD_JOINABLE);

    DBG("[FSS - %s] FSS device instatiated\n", __FUNCTION__);
}

/**
 * fss_class_init() - Set initial properties of the device
 */
static void fss_class_init(ObjectClass *klass, void *data)
{
    DeviceClass *dc = DEVICE_CLASS(klass);

    dc->realize = fss_realize;
}

/*
  Device structure
 */
static const TypeInfo fss_type_info = {
    .name          = TYPE_FSS,
    .parent        = TYPE_SYS_BUS_DEVICE,
    .instance_size = sizeof(FSSState),
    .class_init    = fss_class_init,
};

/**
 * fss_register_types() - Register the device
 */
static void fss_register_types(void)
{
    type_register_static(&fss_type_info);
}

type_init(fss_register_types)
