/* Driver for grups of pins in AXI GPIO blocks
 * 
 * Copyright (C) 2018 by Wojciech M. Zabolotny
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
#define DEVICE_NAME "multi-gpio"
#define CLASS_NAME "class_multi_gpio"

static struct t_dev_state {
  int n_of_dev;
} dev_states;

//It is a dirty trick, but we can service only one device :-(
static struct platform_device * my_pdev = NULL;
static dev_t my_dev=0;
static struct cdev *my_cdev = NULL;
static struct class *my_class = NULL;

struct gpio_descs *g_dout1 = NULL , *g_dout2 = NULL, *g_din = NULL;

//Store result buffer to gpio
static ssize_t gpio_store(struct device *dev, struct gpio_descs *gds, const char *buf, size_t size)
{
   long val;
   int res;
   int i;
   long mask = 1;
   res=kstrtol(buf, 0, &val);
   if(res<0) return res;
   for(i=0;i<gds->ndescs;i++) {
      gpiod_set_value(gds->desc[i],(val & mask) ? 1 : 0);
      mask <<= 1;
   }
   return 0;
}

static ssize_t gpio_show(struct gpio_descs *gds, char *buf)
{
   long val=0;
   int res;
   int i;
   long mask = 1;
   for(i=0;i<gds->ndescs;i++) {
      res=gpiod_get_value(gds->desc[i]);
      if(res<0) return res;
      if(res) val |= mask;
      mask <<= 1;
   }
   res=snprintf(buf,PAGE_SIZE,"%ld",val);
   return res;
}


static ssize_t dout1_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t size)
{
  int res;
  struct t_dev_state * ds = dev_get_drvdata(dev);
  printk(KERN_INFO "dout1 in device %d set to %s\n", ds->n_of_dev,buf);
  res = gpio_store(dev,g_dout1,buf,size);
  if(res<0) return res;
  return size;
}

static ssize_t dout2_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t size)
{
  int res;
  struct t_dev_state * ds = dev_get_drvdata(dev);
  printk(KERN_INFO "dout2 in device %d set to %s\n", ds->n_of_dev,buf);
  res = gpio_store(dev,g_dout2,buf,size);
  if(res<0) return res;
  return size;
}


static ssize_t din_show(struct device *dev, struct device_attribute *attr, char *buf)
{
  int res;
  struct t_dev_state * ds = dev_get_drvdata(dev);
  res = gpio_show(g_din,buf);
  if(res<0) return res;
  printk(KERN_INFO "atr1 in device %d is equal to %s\n", ds->n_of_dev,buf);
  return res;
}

DEVICE_ATTR_WO(dout1);
DEVICE_ATTR_WO(dout2);
DEVICE_ATTR_RO(din);

/* List of attributes of our device */
static struct attribute *mydev_attributes[] ={
   & dev_attr_dout1.attr,
   & dev_attr_dout2.attr,
   & dev_attr_din.attr,
   NULL,
};

/* Group of attributes of our device  */
static struct  attribute_group mydev_attrgrp ={
  .attrs = mydev_attributes,
};

/* List of groups of attributes of our device */
static const struct  attribute_group *mydev_attrgrps[] ={
  &mydev_attrgrp,
  NULL,
};

static void my_dev_cleanup(void)
{
  int i;
  printk(KERN_ALERT "MULTI GPIO dev says good bye\n");
  /* deregister the class */
  if(my_dev && my_class) {
      device_destroy(my_class,MKDEV(MAJOR(my_dev),MINOR(my_dev)));
  }
  if(my_cdev) cdev_del(my_cdev);
  my_cdev=NULL;
  /* release device number */
  unregister_chrdev_region(my_dev, 1);
  /* destroy the class */
  if(my_class) {
    class_destroy(my_class);
    my_class=NULL;
  }

}

struct file_operations fops = {
  .owner = THIS_MODULE,
};


static int my_dev_create(void)
{
  int res,i;
  printk(KERN_ALERT "Welcome to MULTI GPIO dev\n");
  /* Create the class for our device */
  my_class = class_create(THIS_MODULE, CLASS_NAME);
  if (IS_ERR(my_class)) {
    printk(KERN_ERR "Error creating my_class class.\n");
    res=PTR_ERR(my_class);
    goto err1;
  }  /*Get the device number */
  res=alloc_chrdev_region(&my_dev, 0, 1, DEVICE_NAME);
  if(res) {
    printk ("<1>Alocation of the device number for %s failed\n",
            DEVICE_NAME);
    goto err1; 
  };  
  my_cdev = cdev_alloc();
  if (my_cdev==NULL) {
    printk (KERN_ERR "Allocation of cdev for %s failed\n", DEVICE_NAME);
    res = -ENODEV;
    goto err1;
  }
  my_cdev->ops = &fops;
  my_cdev->owner = THIS_MODULE;
  /* Add device to the system */
  res=cdev_add(my_cdev, my_dev, 1);
  if(res) {
    printk (KERN_ERR "Registration of the device number for %s failed\n",
            DEVICE_NAME);
    goto err1;
  };
  /* Create our device */
  device_create_with_groups(my_class,NULL,MKDEV(MAJOR(my_dev),MINOR(my_dev)+i),&dev_states, mydev_attrgrps, "my_dev%d",MINOR(my_dev));
  printk (KERN_ALERT "Registeration is a success. The major device number %s is %d.\n",
	  DEVICE_NAME,
	  MAJOR(my_dev));
  return SUCCESS;
err1:
  my_dev_cleanup();
  return res;
}


void cleanup_tst1( void );
int init_tst1( void );

int tst1_remove(struct platform_device *pdev )
{
  if(my_pdev == pdev) {
    if(g_dout1) {
      devm_gpiod_put_array(&pdev->dev, g_dout1);
    }
    if(g_dout2) {
      devm_gpiod_put_array(&pdev->dev, g_dout2);
    }
    if(g_din) {
      devm_gpiod_put_array(&pdev->dev, g_din);
    }
    my_dev_cleanup();
    return 0;
  } else {
    return -ENODEV;
  }
}

static int tst1_probe(struct platform_device *pdev)
{
  int res = 0;
  printk(KERN_INFO "MULTI GPIO probe called: %p\n", my_pdev);
  if (my_pdev) {
    //We can't handle more than one device
    printk(KERN_INFO "The driver handles already one device: %p\n", my_pdev);
    return -EINVAL;
  }
  //Now we connect the GPIOs
  //Here we test the GPIO access
  g_dout1 = devm_gpiod_get_array(&pdev->dev, "dout1", GPIOD_OUT_HIGH);    
  if(IS_ERR(g_dout1)) {
    res = (int) g_dout1;
    printk (KERN_ERR "I can't connect to the DOUT1 GPIO: error %d\n",res);
    g_dout1 = NULL;
    goto err1;
  };
  g_dout2 = devm_gpiod_get_array(&pdev->dev, "dout2", GPIOD_OUT_HIGH);    
  if(IS_ERR(g_dout2)) {
    res = (int) g_dout2;
    printk (KERN_ERR "I can't connect to the DOUT2 GPIO: error %d\n",res);
    g_dout2 = NULL;
    goto err1;
  };
  g_din = devm_gpiod_get_array(&pdev->dev, "din", GPIOD_IN);    
  if(IS_ERR(g_din)) {
    res = (int) g_din;
    printk (KERN_ERR "I can't connect to the DIN GPIO: error %d\n",res);
    g_din = NULL;
    goto err1;
  };
  res = my_dev_create();
  if(res<0) return res;
  res = SUCCESS;
  my_pdev = pdev;
  printk(KERN_INFO "KSGPIO probe successfull g_dout1=%d, g_dout2=%d, g_din=%d\n", g_dout1->ndescs, g_dout2->ndescs, g_din->ndescs);
  return res;
 err1:
  tst1_remove(pdev);
  return res;
}

//We connect to the platform device
static struct of_device_id multi_gpio_driver_ids[] = {
  {
    .compatible = "wzab,multi-gpio",
  },
  {},
};

static struct platform_driver my_driver = {
  .driver = { 
    .name = DEVICE_NAME,
    .of_match_table = multi_gpio_driver_ids,
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
  printk(KERN_ALERT "Welcome to MULTI GPIO\n");
  return platform_driver_register(&my_driver);
}


static void tst1_cleanup_module(void)
{
  printk(KERN_ALERT "MULTI GPIO says good-bye\n");
  platform_driver_unregister(&my_driver);
}

//Exported function to check status of the GPIOS
int multi_gpio_check_status(void)
{
  if(my_pdev && g_dout1 && g_dout2 && g_din) return SUCCESS;
  else return -ENODEV;
}
/*
//Exported functions to control GPIOS
int ksgpio_set_start(int val) 
{
  if(g_start) {
    gpiod_set_value(g_start,val);
    return SUCCESS;
  } else {
    return -ENODEV;
  }

}

int ksgpio_set_reset(int val) 
{
  if(g_reset) {
    gpiod_set_value(g_reset,val);
    return SUCCESS;
  } else {
    return -ENODEV;
  }
}
*/
EXPORT_SYMBOL_GPL(multi_gpio_check_status);

module_init(tst1_init_module);
module_exit(tst1_cleanup_module);

