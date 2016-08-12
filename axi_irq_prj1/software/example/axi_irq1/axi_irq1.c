/* Quick and dirty AXI Bus Mastering device driver
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
#include <linux/dma-direction.h>
#include <linux/dma-mapping.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/sched.h>
#include <linux/mm.h>
#include <asm/io.h>
#include <linux/interrupt.h>
#include <asm/uaccess.h>
#define SUCCESS 0
#define DEVICE_NAME "wzab_irq1"

//Global variables used to store information about WZAB_BM1
//This must be changed, if we'd like to handle multiple WZAB_BM1 instances
static volatile uint32_t * fmem=NULL; //Pointer to registers area

//It is a dirty trick, but we can service only one device :-(
static struct platform_device * my_pdev = NULL;
int irq = -1;
int irq_set = -1;
static int phys_addr = 0;

void cleanup_tst1( void );
void cleanup_tst1( void );
int init_tst1( void );
static int tst1_open(struct inode *inode, struct file *file);
static int tst1_release(struct inode *inode, struct file *file);
ssize_t tst1_read(struct file *filp,
		  char __user *buf,size_t count, loff_t *off);
ssize_t tst1_write(struct file *filp,
		   const char __user *buf,size_t count, loff_t *off);
loff_t tst1_llseek(struct file *filp, loff_t off, int origin);

int tst1_mmap(struct file *filp, struct vm_area_struct *vma);

dev_t my_dev=0;
struct cdev * my_cdev = NULL;
static struct class *class_my_tst = NULL;

struct file_operations Fops = {
  .owner = THIS_MODULE,
  .read=tst1_read, /* read */
  .write=tst1_write, /* write */
  .open=tst1_open,
  .release=tst1_release,  /* a.k.a. close */
  .llseek=no_llseek,
  //.mmap=tst1_mmap
};

/* Queue for reading process */
DECLARE_WAIT_QUEUE_HEAD (readqueue);

ssize_t tst1_read(struct file *filp,
                  char __user *buf,size_t count, loff_t *off)
{
  uint64_t val;
  if (count != 8) return -EINVAL; //Only 8-byte accesses allowed
  {
    ssize_t res;
    //Interrupts are on, so we should sleep and wait for interrupt
    res=wait_event_interruptible(readqueue, (fmem[0xC/4] & 2) == 0);
    if(res) return res; //Signal received!
  }
  //Read counter
  val = * (uint64_t *) &fmem[0x0/4];
  if(__copy_to_user(buf,&val,8)) return -EFAULT;
  return 8;
}


ssize_t tst1_write(struct file *filp,
		   const char __user *buf,size_t count, loff_t *off)
{
  uint32_t val[2];
  if (count != 8) return -EINVAL; //Only 4-byte access allowed
  __copy_from_user(&val,buf,8);
  //Clear the load and irq_enable bits
  fmem[0xC/4] &= ~6;
  mb();
  //Set the counter
  fmem[0x0/4]=val[0];
  fmem[0x4/4]=val[1];
  mb();
  fmem[0xC/4] |= 4;
  mb();
  fmem[0xC/4] &= ~4;
  mb();
  fmem[0xC/4] |= 2;
  return 8;
}
/* Cleanup resources */
int tst1_remove(struct platform_device *pdev )
{
  if(my_dev && class_my_tst) {
    device_destroy(class_my_tst,my_dev);
  }
  if(fmem) {
      iounmap(fmem);
      fmem = NULL;
  }
  if(my_cdev) cdev_del(my_cdev);
  my_cdev=NULL;
  unregister_chrdev_region(my_dev, 1);
  if(class_my_tst) {
    class_destroy(class_my_tst);
    class_my_tst=NULL;
  }
  //printk("<1>drv_tst1 removed!\n");
  if(my_pdev == pdev) {
      printk(KERN_INFO "Device %p removed !\n", pdev);
      my_pdev = NULL;
  }
  return 0;
}

/* Interrupt service routine */
irqreturn_t tst1_irq(int irq, void * dev_id)
{
  // First we check if our device requests interrupt
  //printk("<1>I'm in interrupt!\n");
  if(fmem[0x8/4] & 4) {
    //Yes, this is our device
    //Stop the counter and disable interrupt
    fmem[0xC/4] &= ~2;    
    //Wake up the reading process
    wake_up_interruptible(&readqueue);
    return IRQ_HANDLED;
  }
  return IRQ_NONE; //Our device does not request interrupt
};

static int tst1_open(struct inode *inode, 
		     struct file *file)
{
  int res=0;
  nonseekable_open(inode, file);
  res=request_irq(irq,tst1_irq,IRQF_SHARED,DEVICE_NAME,my_pdev); //Should be changed for multiple WZENC1s
  if(res) {
    printk (KERN_INFO "wzab_tst1: I can't connect irq %d error: %d\n", irq,res);
    irq_set = -1;
  } else {
    printk (KERN_INFO "wzab_tst1: Connected irq %d\n", irq);
    irq_set = 1;
  }
  return SUCCESS;
}

static int tst1_release(struct inode *inode, 
			struct file *file)
{
  fmem[0xC/4] &= ~2; //Disable IRQ
  if(irq_set>=0) {
    free_irq(irq,my_pdev); //Free interrupt
    irq_set = -1;
  }
  return SUCCESS;
}

void tst1_vma_open (struct vm_area_struct * area)
{  }

void tst1_vma_close (struct vm_area_struct * area)
{  }

static struct vm_operations_struct tst1_vm_ops = {
  .open=tst1_vma_open,
  .close=tst1_vma_close,
};


static int tst1_probe(struct platform_device *pdev)
{

  int res = 0;
  struct resource * resptr = NULL;
  if (my_pdev) {
      //We can't handle more than one device
      printk(KERN_INFO "The driver handles already one device: %p\n", my_pdev);
      return -EINVAL;
  }
  irq = platform_get_irq(pdev,0);
  if(irq<0) {
    printk(KERN_ERR "Error reading the IRQ number: %d.\n",irq);
    res=irq;
    goto err1;
  }
  printk(KERN_INFO "Connected IRQ=%d\n",irq);
  resptr = platform_get_resource(pdev,IORESOURCE_MEM,0);
  if(resptr==0) {
    printk(KERN_ERR "Error reading the register addresses.\n");
    res=-EINVAL;
    goto err1;
  }
  phys_addr = resptr->start; //No check for size?
  fmem = ioremap(phys_addr,0x1000);
  if(!fmem) {
    printk ("<1>Mapping of memory for %s registers failed\n",
	    DEVICE_NAME);
    res= -ENOMEM;
    goto err1;
  }
  //Create the class
  class_my_tst = class_create(THIS_MODULE, "my_dma_class");
  if (IS_ERR(class_my_tst)) {
    printk(KERN_ERR "Error creating my_tst class.\n");
    res=PTR_ERR(class_my_tst);
    goto err1;
  }
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
  device_create(class_my_tst,NULL,my_dev,NULL,"my_bm%d",MINOR(my_dev));
  printk (KERN_INFO "%s The major device number is %d.\n",
	  "Registeration is a success.",
	  MAJOR(my_dev));
  printk(KERN_INFO "Registred device at: %p\n",pdev);
  my_pdev = pdev;
  return 0;
 err1:
  if (fmem) {
      iounmap(fmem);
      fmem = NULL;
  }
  return res;
}

//We connect to the platform device
static struct of_device_id wzcdma1_driver_ids[] = {
  {
    .compatible = "xlnx,wzab-ip-ms-v1-0-1.0",
  },
  {},
};

static struct platform_driver my_driver = {
	.driver = { 
           .name = DEVICE_NAME,
           .of_match_table = wzcdma1_driver_ids,
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
  printk(KERN_ALERT "Witam serdecznie\n");
  return platform_driver_register(&my_driver);
}


static void tst1_cleanup_module(void)
{
  printk(KERN_ALERT "Do widzenia\n");
  platform_driver_unregister(&my_driver);
}


module_init(tst1_init_module);
module_exit(tst1_cleanup_module);

