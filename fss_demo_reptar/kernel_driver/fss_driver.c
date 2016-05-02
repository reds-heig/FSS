/*****************************************************************
 * fss_driver - Kernel driver for FSS                            *
 *                                                               *
 * FSS project - REDS Institute, HEIG-VD, Yverdon-les-Bains (CH) *
 *  A. Dassatti, A. Convers, R. Rigamonti, X. Ruppen -- 12.2015  *
 *****************************************************************/

#include <linux/init.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/miscdevice.h>
#include <asm/io.h>
#include <asm/uaccess.h>
#include <linux/pm_runtime.h>
#include <linux/platform_device.h>
#include <linux/fs.h>
#include <linux/slab.h>
#include <linux/interrupt.h>
#include <linux/sched.h>
#include <linux/spinlock.h>

/* LEDs offset */
#define LED_OFF          0x1D

/**
 * struct fss_dev - Private data of the device
 *
 * @miscdev     : device file
 * @regs        : pointer to mapped memory
 * @dev         : device internals
 * @irq         : IRQ number
 * @irq_received: flag used to mark the reception of an interrupt
 * @q_wait      : waiting queue for the read operation
 * @lock        : spinlock for irq_received access
 */
struct fss_dev {
    struct miscdevice miscdev;
    void __iomem *regs;
    struct device *dev;
    int irq;
    int irq_received;

    wait_queue_head_t q_wait;
    spinlock_t lock;
};

/**
 * irq_handler() - Interrupt Service Routine
 *
 * @irq   : interrupt line number
 * @dev_id: pointer to the structure given in the request_irq call, in our case
 *	    the device's private data
 *
 * Return: IRQ_HANDLED, meaning that the interrupt request has been correctly
 *         handled
 */
static irqreturn_t irq_handler(int irq, void *dev_id)
{
    struct fss_dev *dev = (struct fss_dev *)dev_id;
    unsigned long flags;

    spin_lock_irqsave(&dev->lock, flags);
    dev->irq_received = 1;
    spin_unlock_irqrestore(&dev->lock, flags);

    wake_up_interruptible(&dev->q_wait);

    return IRQ_HANDLED;
}

/**
 * fss_write() - Write operation on the device file
 *
 * In this version, the write operation simply takes the value written on the
 * device file by the userspace program and writes it at the LED's register
 * address.
 *
 * @filp : pointer to file device
 * @buf  : user-space buffer from which data will be read
 * @count: size of the data to be written
 * @f_pos: position offset in file -- unused in our case
 *
 * Return: The number of written bytes (two, in this case) on success, a
 *         negative number if an error occurs.
 *         In particular, -EFAULT is returned if copy_to_user() fails.
 */
static ssize_t fss_write(struct file *filp, const char __user *buf,
			 size_t count, loff_t *f_pos)
{
    u16 tmp;

    struct fss_dev *dev = container_of(filp->private_data,
				       struct fss_dev,
			   	       miscdev);

    if (copy_from_user(&tmp, buf, sizeof(u16))) {
	return -EFAULT;
    }

    iowrite16((u16)tmp, (u16 *)dev->regs + LED_OFF);

    return sizeof(u16);
}

/**
 * fss_read() - Read operation on the device file
 *
 * In this version the reader stays locked on the read, waiting for a character
 * to arrive. When an interrupt is received, the ISR wakes up the read operation
 * which in turn writes a character on the device, unblocking the userspace
 * reader.
 *
 * @filp : pointer to file device
 * @buf  : user-space buffer where read data will be put
 * @count: size of the data to be read
 * @f_pos: position offset in file -- unused in our case
 *
 * Return: The number of read bytes (one, in this case) on success, a negative
 *         number if an error occurs.
 *         In particular, -ERESTARTSYS is returned if a sleeping read is woken
 *         up by an external signal, and -EFAULT if copy_to_user() fails.
 */
static ssize_t fss_read(struct file *filp, char __user *buf,
			size_t count, loff_t *f_pos)
{
    const char tmp = 1;
    int rc;
    unsigned long flags;

    struct fss_dev *dev = container_of(filp->private_data,
				       struct fss_dev,
				       miscdev);

    while (dev->irq_received == 0) {
	rc = wait_event_interruptible(dev->q_wait,
				      dev->irq_received != 0);
	if (rc) {
	    return -ERESTARTSYS;
	}
    }

    spin_lock_irqsave(&dev->lock, flags);
    dev->irq_received = 0;
    spin_unlock_irqrestore(&dev->lock, flags);

    if (copy_to_user(buf, &tmp, 1)) {
    	pr_err("copy_to_user() error!\n");
    	return -EFAULT;
    }

    return 1;
}

/**
 * struct fss_ops - Operations allowed on the device file
 */
static const struct file_operations fss_fops = {
    .owner = THIS_MODULE,
    .read = fss_read,
    .write = fss_write,
};

/**
 * fss_probe() - Probe function for the device, called on module load
 *
 * @pdev: pointer to the platform device structure
 *
 * Return: 0 on success, a negative number if an error has occurred
 */
static int fss_probe(struct platform_device *pdev)
{
    struct resource *res;
    struct fss_dev *dev;
    int rc;

    if ((dev = devm_kzalloc(&pdev->dev, sizeof(struct fss_dev),
			    GFP_KERNEL)) == NULL) {
	pr_err("Cannot allocate device memory!\n");
	rc = -ENOMEM;
	goto out_exit;
    }

    /* Retrieve the pointer to the mapped memory space */
    if ((res = platform_get_resource(pdev, IORESOURCE_MEM, 0)) == NULL) {
	pr_err("Cannot get memory resource!\n");
	rc = -EINVAL;
	goto out_exit;
    }

    /* Remap memory */
    dev->regs = devm_ioremap_resource(&pdev->dev, res);
    if (!dev->regs) {
	dev_err(&pdev->dev, "Cannot remap registers!\n");
	rc = -ENOMEM;
	goto out_exit;
    }

    dev->dev = &pdev->dev;
    dev->irq = platform_get_irq(pdev, 0);

    platform_set_drvdata(pdev, dev);
    init_waitqueue_head(&dev->q_wait);

    dev->miscdev.minor = MISC_DYNAMIC_MINOR;
    dev->miscdev.name = "fss";
    dev->miscdev.fops = &fss_fops;
    dev->miscdev.parent = &pdev->dev;
    dev->irq_received = 0;

    /* Retrieve the IRQ number */
    if ((rc = devm_request_irq(&pdev->dev, dev->irq, irq_handler, 0,
			       "fss", dev)) < 0) {
	dev_err(&pdev->dev, "devm_request_irq() failed!\n");
	goto out_exit;
    }

    /* Register the device */
    if ((rc = misc_register(&dev->miscdev)) != 0) {
	dev_err(&pdev->dev, "misc_register() failed!\n");
	goto out_exit;
    }

    return 0;

 out_exit:
    return rc;
}

/**
 * fss_remove() - Remove function, called at module unloading
 *
 * @pdev: pointer to the platform device
 *
 * Return: 0
 */
static int fss_remove(struct platform_device *pdev)
{
    struct fss_dev *dev;

    dev = platform_get_drvdata(pdev);
    kfree(dev->miscdev.name);

    misc_deregister(&dev->miscdev);

    return 0;
}

/**
 * struct fss_dt_ids - List of compatible devices
 */
static const struct of_device_id fss_dt_ids[] = {
    { .compatible = "fss" },
    { /* sentinel */ }
};

/**
 * struct fss_driver - Driver structure used when registering the module
 */
static struct platform_driver fss_driver = {
    .driver = {
	.name = "fss",
	.owner = THIS_MODULE,
	.of_match_table = of_match_ptr(fss_dt_ids),
    },
    .probe = fss_probe,
    .remove = fss_remove,
};

module_platform_driver(fss_driver);

MODULE_AUTHOR("REDS");
MODULE_DESCRIPTION("FSS");
MODULE_LICENSE("GPL");
