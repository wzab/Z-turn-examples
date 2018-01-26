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

//Here we define the attributes together with their access 
typedef struct {
 const char * name;
 struct gpio_descs * gdescs;
 struct device_attribute attr;
} my_attr_t;

static my_attr_t my_attrs[]={
  {"dout1",NULL},
  {"dout2",NULL},
  {"din",NULL},
  {NULL,NULL}
};

static struct t_dev_state {
  int n_of_dev;
} dev_states;

//It is a dirty trick, but we can service only one device :-(
static struct platform_device * my_pdev = NULL;
static dev_t my_dev=0;
static struct cdev *my_cdev = NULL;
static struct class *my_class = NULL;

static struct gpio_descs * find_gds(struct device_attribute *attr)
{
   struct gpio_descs * gds = NULL;
   my_attr_t * mattr = &my_attrs[0];
   while(mattr->name) {
	if(!strcmp(mattr->name,attr->attr.name)) {
           gds = mattr->gdescs;
           break;
        }
        mattr++;
   }
   return gds;
}

//Store result buffer to gpio
static ssize_t gpio_store(struct device *dev, struct device_attribute *attr, const char *buf, size_t size)
{
   long val;
   int res;
   int i;
   struct gpio_descs * gds = NULL;
   long mask = 1;
   printk(KERN_INFO "Writing attribute %s : %s\n", attr->attr.name, buf);
   //Find the matching attribute
   gds = find_gds(attr);
   if(gds==NULL) return -ENODEV;
   res=kstrtol(buf, 0, &val);
   if(res<0) return res;
   for(i=0;i<gds->ndescs;i++) {
      gpiod_set_value(gds->desc[i],(val & mask) ? 1 : 0);
      mask <<= 1;
   }
   return size;
}

//Show the state of the gpio
static ssize_t gpio_show(struct device *dev, struct device_attribute *attr, char *buf)
{
   long val=0;
   int res;
   int i;
   struct gpio_descs * gds = NULL;
   long mask = 1;
   //Find the matching attribute
   gds = find_gds(attr);
   if(gds==NULL) return -ENODEV;
   for(i=0;i<gds->ndescs;i++) {
      res=gpiod_get_value(gds->desc[i]);
      if(res<0) return res;
      if(res) val |= mask;
      mask <<= 1;
   }
   res=snprintf(buf,PAGE_SIZE,"%ld",val);
   printk(KERN_INFO "Reading attribute %s : %s\n", attr->attr.name, buf);
   return res;
}

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
  my_attr_t * mattr = &my_attrs[0];
  struct device * dev = NULL;
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
  dev = device_create(my_class,NULL,MKDEV(MAJOR(my_dev),MINOR(my_dev)+i),&dev_states, "my_dev%d",MINOR(my_dev));
  if(IS_ERR(dev)) {
      res = (int) dev;
      printk (KERN_ERR "I can't create device %s: error %d\n",DEVICE_NAME,res);
      goto err1;
      };
  /* Create device files for attributes */
  while(mattr->name) {
     //Below I reconstruct the behavior of __ATTR macro
     //I don't know if it will remain stable in next kernel versions though...
       mattr->attr.attr.name = mattr->name;
       mattr->attr.attr.mode=(S_IWUSR | S_IRUGO);
       mattr->attr.show = gpio_show;
       mattr->attr.store = gpio_store;
     res = device_create_file(dev,&mattr->attr);        
     if(res) {
        printk (KERN_ERR "Creating file for attribute %s failed\n",
            mattr->name);
        goto err1;
        }
     mattr++; 
     }
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
    my_attr_t * mattr=&my_attrs[0];
    while(mattr->name) {
	devm_gpiod_put_array(&pdev->dev, mattr->gdescs);
        mattr->gdescs = NULL;
        mattr++;
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
  my_attr_t * mattr = &my_attrs[0];
  printk(KERN_INFO "MULTI GPIO probe called: %p\n", my_pdev);
  if (my_pdev) {
    //We can't handle more than one device
    printk(KERN_INFO "The driver handles already one device: %p\n", my_pdev);
    return -EINVAL;
  }
  //Now we connect the GPIOs
  while(mattr->name) {
    struct gpio_descs * gds = devm_gpiod_get_array(&pdev->dev, mattr->name, GPIOD_ASIS);
    if(IS_ERR(gds)) {
      res = (int) gds;
      printk (KERN_ERR "I can't connect to the GPIO group %s: error %d\n",mattr->name,res);
      goto err1;
      };
    mattr->gdescs = gds;
    mattr++;
   }
  res = my_dev_create();
  if(res<0) return res;
  res = SUCCESS;
  my_pdev = pdev;
  printk(KERN_INFO "MULTI GPIO probe successfull\n");
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

/*

//Exported function to check status of the GPIOS
int multi_gpio_check_status(void)
{
  if(my_pdev && g_dout1 && g_dout2 && g_din) return SUCCESS;
  else return -ENODEV;
}
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
EXPORT_SYMBOL_GPL(multi_gpio_check_status);
*/

module_init(tst1_init_module);
module_exit(tst1_cleanup_module);

