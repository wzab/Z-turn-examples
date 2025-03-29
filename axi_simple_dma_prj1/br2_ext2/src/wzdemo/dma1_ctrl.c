/* 
 * Copyright (C) 2025 by Wojciech M. Zabolotny
 * wojciech.
 * Significantly based on multiple drivers included in
 * sources of Linux
 * Therefore this source is licensed under GPL v2
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <asm/uaccess.h>
MODULE_LICENSE("GPL v2");
#include <linux/device.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/sched.h>
#include <linux/mm.h>
#include <asm/io.h>
#include <linux/interrupt.h>
#include <linux/uaccess.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_platform.h>
#include <linux/kfifo.h>
#include "dma1.h"


#define SUCCESS 0
#define DEVICE_NAME "dma_ctrl"

//Global variables used to store information about WZctrl1
//This must be changed, if we'd like to handle multiple WZctrl1 instances

//addresses of the crucial registers
volatile uint32_t * ctrl_base = NULL;

void cleanup_ctrl1( void );
int init_ctrl1( void );

/* Cleanup resources */
int ctrl1_remove( struct platform_device * pdev )
{
    if(ctrl_base) { iounmap(ctrl_base); ctrl_base = NULL; };
    return SUCCESS;
}

static void dispres(struct resource * rptr)
{
   printk(KERN_ERR "Resource: %s start: %x, end %x", rptr->name, rptr->start, rptr->end);
}

/*
static void disppdev(struct platform_device * dptr)
{
   printk(KERN_ERR "Device: %s with: %x resources", dptr->name, dptr->num_resources);
}
*/

static int ctrl1_probe(struct platform_device * pdev)
{
    int res = SUCCESS;
    struct resource * rptr;

    printk(KERN_ERR "Getting ctrl_base.\n");
    ctrl_base = (volatile uint32_t *) devm_platform_get_and_ioremap_resource(pdev,0,&rptr);
    if(IS_ERR((void *) ctrl_base)) {
        printk(KERN_ERR "Error obtaining the dma_core.\n");
        res=-EINVAL;
        goto err1;
        }
    dispres(rptr);
    return res;
err1:
    ctrl1_remove(pdev);
    return res;
}

static struct of_device_id ctrl1_driver_ids[] = {
    {
        .compatible = "xlnx,hls-dma-ctrl-v1-0-S00-AXI-1.0",
    },
    {},
};
struct platform_driver my_driver = {
    .driver = {
        .name = "wz-ctrl1-ctrl",
        .of_match_table = ctrl1_driver_ids,
    },
    .probe = ctrl1_probe,
    .remove = ctrl1_remove,
};

static int my_init(void)
{
    int ret = platform_driver_register(&my_driver);
    if (ret < 0) {
        printk(KERN_ERR "Failed to register my platform driver: %d\n",ret);
        return ret;
    }
    printk(KERN_ALERT "Witam serdecznie\n");
    return 0;
}
static void my_exit(void)
{
    platform_driver_unregister(&my_driver);
    printk(KERN_ALERT "Do widzenia\n");
}

// Functions providing access to the control lines

void dma1_set_ctrl(uint32_t val)
{
  * (ctrl_base + 2) = val; 
}

void dma1_set_base(uint32_t val)
{
  * (ctrl_base + 1) = val; 
}

uint32_t dma1_get_id(void)
{
  return * ctrl_base;
}

uint32_t dma1_get_status(void)
{
  return * (ctrl_base + 3);
}

EXPORT_SYMBOL_GPL(dma1_set_ctrl);
EXPORT_SYMBOL_GPL(dma1_set_base);
EXPORT_SYMBOL_GPL(dma1_get_id);
EXPORT_SYMBOL_GPL(dma1_get_status);

module_init(my_init);
module_exit(my_exit);

