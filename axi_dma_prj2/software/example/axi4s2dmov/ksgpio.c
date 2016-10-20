/* Driver for AXI GPIO blocks controlled from kernel space
 * 
 * Copyright (C) 2016 by Wojciech M. Zabolotny
 * wzab<at>ise.pw.edu.pl
 * Significantly based on multiple drivers included in
 * sources of Linux
 * Therefore this source is licensed under GPL v2
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <asm/uaccess.h>
MODULE_LICENSE("GPL v2");
#include <linux/device.h>
#include <linux/platform_device.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/sched.h>
#include <linux/delay.h>
#include <linux/mm.h>
#include <linux/dma-mapping.h>
#include <linux/io.h>
#include <linux/interrupt.h>
#include <linux/gpio/consumer.h>
#include <asm/uaccess.h>

#define SUCCESS 0
#define DEVICE_NAME "ksgpio"
#define CLASS_NAME "class_ksgpio"


//It is a dirty trick, but we can service only one device :-(
static struct platform_device * my_pdev = NULL;

struct gpio_desc *g_start = NULL , * g_reset = NULL;

void cleanup_tst1( void );
int init_tst1( void );

int tst1_remove(struct platform_device *pdev )
{
    if(g_start) {
	devm_gpiod_put(&pdev->dev, g_start);
    }
    if(g_reset) {
	devm_gpiod_put(&pdev->dev, g_reset);
    }
    return 0;
}

static int tst1_probe(struct platform_device *pdev)
{
    int res = 0;
    if (my_pdev) {
        //We can't handle more than one device
        printk(KERN_INFO "The driver handles already one device: %p\n", my_pdev);
        return -EINVAL;
    }
    //Now we connect the GPIOs
    //Here we test the GPIO access
    g_start = devm_gpiod_get_index(&pdev->dev, "myctl", 1, GPIOD_OUT_HIGH);    
    if(IS_ERR(g_start)) {
        res = (int) g_start;
        printk (KERN_ERR "I can't connect to the START GPIO: error %d\n",res);
        g_start = NULL;
        goto err1;
    };
    g_reset = devm_gpiod_get_index(&pdev->dev, "myctl", 0, GPIOD_OUT_HIGH);    
    if(IS_ERR(g_reset)) {
        res = (int) g_reset;
        printk (KERN_ERR "I can't connect to the RESET GPIO: error %d\n",res);
        g_reset = NULL;
        goto err1;
    };
    res = SUCCESS;
    return res;
    err1:
      tst1_remove(pdev);
    return res;
}

//We connect to the platform device
static struct of_device_id ksgpio_driver_ids[] = {
    {
        .compatible = "wzab,ksgpio",
    },
    {},
};

static struct platform_driver my_driver = {
    .driver = { 
        .name = DEVICE_NAME,
        .of_match_table = ksgpio_driver_ids,
    },
    .probe = tst1_probe,
    .remove = tst1_remove,
};

static int tst1_init_module(void)
{
    /* when a module, this is printed whether or not devices are found in probe */
    #ifdef MODULE
    //  printk(version);
    #endif
    printk(KERN_ALERT "Welcome to KSGPIO\n");
    return platform_driver_register(&my_driver);
}


static void tst1_cleanup_module(void)
{
    printk(KERN_ALERT "KSGPIO says good-bye\n");
    platform_driver_unregister(&my_driver);
}

//Exported functions to control GPIOS
void ksgpio_set_start(int val) 
{
    gpiod_set_value(g_start,val);
}

void ksgpio_set_reset(int val) 
{
    gpiod_set_value(g_reset,val);
}

EXPORT_SYMBOL_GPL(ksgpio_set_start);
EXPORT_SYMBOL_GPL(ksgpio_set_reset);

module_init(tst1_init_module);
module_exit(tst1_cleanup_module);

