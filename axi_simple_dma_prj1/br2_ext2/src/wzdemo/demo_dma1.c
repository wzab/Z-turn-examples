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
#include <linux/dma-mapping.h>
#include <linux/uaccess.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/of_platform.h>
#include <linux/kfifo.h>
#include "dma1.h"


#define SUCCESS 0
#define DEVICE_NAME "dma_demo"
#define LOG2_N_PAGES 4

//Global variables used to store information about WZdma1
//This must be changed, if we'd like to handle multiple WZdma1 instances

//addresses of the crucial registers
volatile uint32_t * dma_core = NULL;
//addresses of the DMA buffer
volatile uint8_t * dma_buffer = NULL;
dma_addr_t dma_addr = 0;
#define DMA_BUFFER_SIZE 8192

void cleanup_dma1( void );
int init_dma1( void );
static int dma1_open(struct inode *inode, struct file *file);
static int dma1_release(struct inode *inode, struct file *file);
ssize_t dma1_read(struct file *filp,
                  char __user *buf,size_t count, loff_t *off);
ssize_t dma1_write(struct file *filp,
                   const char __user *buf,size_t count, loff_t *off);
int dma1_mmap(struct file *filp, struct vm_area_struct *vma);

int is_open = 0; //Flag informing if the device is open
dev_t my_dev=0;
struct cdev * my_cdev = NULL;
static struct class *class_my_dma = NULL;

struct file_operations Fops = {
    .owner = THIS_MODULE,
    .read=dma1_read, /* read */
    .write=dma1_write, /* write */
    .open=dma1_open,
    .release=dma1_release,  /* a.k.a. close */
    .llseek=no_llseek,
    .mmap = dma1_mmap,
};

/* Cleanup resources */
int dma1_remove( struct platform_device * pdev )
{
    if(my_dev && class_my_dma) {
        device_destroy(class_my_dma,my_dev);
    }
    if(dma_buffer) {dma_free_coherent(&pdev->dev,DMA_BUFFER_SIZE,dma_buffer,dma_addr); dma_buffer = NULL; };
    if(dma_core) { iounmap(dma_core); dma_core = NULL; };
    if(my_cdev) cdev_del(my_cdev);
    my_cdev=NULL;
    unregister_chrdev_region(my_dev, 1);
    if(class_my_dma) {
        class_destroy(class_my_dma);
        class_my_dma=NULL;
    }
    //printk("<1>drv_dma1 removed!\n");
    return SUCCESS;
}

static int dma1_open(struct inode *inode,
                     struct file *file)
{
    if(is_open) return -EBUSY; //May be opened only once!
    return SUCCESS;
}

static int dma1_release(struct inode *inode,
                        struct file *file)
{
    is_open=0;
    return SUCCESS;
}

ssize_t dma1_read(struct file *filp,
                  char __user *buf,size_t count, loff_t *off)
{
    return -EINVAL;
}

ssize_t dma1_write(struct file *filp,
                   const char __user *buf,size_t count, loff_t *off)
{
    return -EINVAL;
}


void dma1_vma_open (struct vm_area_struct * area)
{  }

void dma1_vma_close (struct vm_area_struct * area)
{  }

static struct vm_operations_struct dma1_vm_ops = {
    .open=dma1_vma_open,
    .close=dma1_vma_close,
};

int dma1_mmap(struct file *filp,
              struct vm_area_struct *vma)
{
    return -EINVAL;
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

static int dma1_probe(struct platform_device * pdev)
{
    int res = SUCCESS;
    struct device_node * symbols;
    struct device_node * tmpnode;
    struct platform_device * tmppdev;
    struct resource * rptr;

    printk(KERN_ERR "Getting dma_core.\n");
    dma_core = (volatile uint32_t *) devm_platform_get_and_ioremap_resource(pdev,0,&rptr);
    if(IS_ERR((void *)dma_core)) {
        printk(KERN_ERR "Error obtaining the dma_core.\n");
        res=-EINVAL;
        goto err1;
        }
    dispres(rptr);

    // Allocate the DMA buffer
    dma_buffer = (volatile uint8_t *) dma_alloc_coherent(&pdev->dev,8192,&dma_addr, GFP_USER);
    if (IS_ERR(dma_buffer)) {
        printk(KERN_ERR "Error creating dma buffer.\n");
        res=PTR_ERR(class_my_dma);
        goto err1;
    }
    printk("Allocated DMA buffer at %x with DMA address: %x\n", dma_buffer,dma_addr);
    dma1_set_base(dma_addr);
  

    class_my_dma = class_create("my_dma_class");
    if (IS_ERR(class_my_dma)) {
        printk(KERN_ERR "Error creating my_dma class.\n");
        res=PTR_ERR(class_my_dma);
        goto err1;
    }
    
    // Remap it for DMA
    
    /* Alocate device number */
    res=alloc_chrdev_region(&my_dev, 0, 1, DEVICE_NAME);
    if(res) {
        printk ("<1>Alocation of the device number for %s failed\n",
                DEVICE_NAME);
        goto err1;
    };
    my_cdev = cdev_alloc( );
    if(my_cdev == NULL) {
        printk ("<1>Allocation of cdev for %s failed\n",
                DEVICE_NAME);
        goto err1;
    }
    my_cdev->ops = &Fops;
    my_cdev->owner = THIS_MODULE;
    /* Add character device */
    res=cdev_add(my_cdev, my_dev, 1);
    if(res) {
        printk ("<1>Registration of the device number for %s failed\n",
                DEVICE_NAME);
        goto err1;
    };
    device_create(class_my_dma,NULL,my_dev,NULL,"my_dma%d",MINOR(my_dev));
    printk ("<1>%s The major device number is %d.\n",
            "Successful registration.",
            MAJOR(my_dev));
    return 0;
err1:
    dma1_remove(pdev);
    return res;
}

static struct of_device_id dma1_driver_ids[] = {
    {
        .compatible = "xlnx,dma1-1.35",
    },
    {},
};
struct platform_driver my_driver = {
    .driver = {
        .name = "wz-demo-dma1",
        .of_match_table = dma1_driver_ids,
    },
    .probe = dma1_probe,
    .remove = dma1_remove,
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

module_init(my_init);
module_exit(my_exit);

