/* Driver for AXI4Stream source connected via AXI DataMover
 * 
 * Copyright (C) 2016 by Wojciech M. Zabolotny
 * wzab<at>ise.pw.edu.pl
 * Significantly based on multiple drivers included in
 * sources of Linux
 * Therefore this source is licensed under GPL v2
 * WARNING!
 * The driver handles a single axi4s2dmov device! 
 * For handling of multiple devices the global variables
 * must be moved into structures associated with 
 * individual devices!
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <asm/uaccess.h>
MODULE_LICENSE("GPL");
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
#include "axi4s2dmov.h"

#define SUCCESS 0
#define DEVICE_NAME "wzab_axi4s2dmov"
#define CLASS_NAME "class_axi4s2dmov"


//AXI FIFO REGISTERS
#define AF_STR_RESET 0x28
#define AF_TX_RESET 0x8
#define AF_RX_RESET 0x18
#define AF_ISR 0x00
#define AF_IER 0x04
#define AF_RDFD 0x20
#define AF_RDFO 0x1c
#define AF_TDFD 0x10
#define AF_TLR 0x14
#define AF_RLR 0x24

//Global variables used to store information about WZAB_BM1
//This must be changed, if we'd like to handle multiple WZAB_BM1 instances
static void * fmem=NULL; //Pointer to registers area

static resource_size_t phys_addr = 0;
static resource_size_t phys_len = 0;

static uint32_t * virt_buf[BUF_NUM] = {[0 ... BUF_NUM-1] = NULL};
static dma_addr_t phys_buf[BUF_NUM] = {[0 ... BUF_NUM-1] = 0};
volatile static int blen[BUF_NUM] = {[0 ... BUF_NUM-1] = 0}; //Number of bytes in the buffer
volatile static int bready[BUF_NUM] = {[0 ... BUF_NUM-1] = 0}; //Info if the buffer is ready
static int received_buf = 0;
volatile static int exp_buf = 0;
static int is_started = 0;

int irq = -1;
int irq_set = -1;

//It is a dirty trick, but we can service only one device :-(
static struct platform_device * my_pdev = NULL;

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
long tst1_ioctl(struct file *, unsigned int, unsigned long);

//Functions provided by the ksgpio module
int ksgpio_set_start(int val);
int ksgpio_set_reset(int val) ;
int ksgpio_check_status(void);

DECLARE_WAIT_QUEUE_HEAD (readqueue);


dev_t my_dev=0;
struct cdev * my_cdev = NULL;
static struct class *class_my_tst = NULL;

struct file_operations Fops = {
  .owner = THIS_MODULE,
  //.read=tst1_read, /* read */
  //.write=tst1_write, /* write */
  .open=tst1_open,
  .release=tst1_release,  /* a.k.a. close */
  .unlocked_ioctl = tst1_ioctl,
  //.llseek=no_llseek,
  .mmap=tst1_mmap
};

irqreturn_t tst1_irq(int irq, void * dev_id)
{
  int res;
  int nbuf;
  volatile uint32_t * regs;
  regs = (volatile uint32_t *) fmem;
  // First we check if our device requests interrupt
  //printk("<1>I'm in interrupt!\n");
  if(regs[AF_ISR/4] & 0x04000000) {
    //Yes, this is our interrupt
    regs[AF_ISR/4] = 0xffffffff; //Clear interrupts why all!?
    mb();
    while(1) {
      res = regs[AF_RDFO/4]; //FIFO occupancy
      if(res==0) break; //No more packets to receive
      res = regs[AF_RLR/4];
      if(res != 4) {
	//This is an incorrect response, how we can handle it?
	printk( KERN_ERR "Incorrect length of AXI DM status: %d, but should be 4\n",res);
	break; //Should we really leave? How to restore proper operation?
      }
      //res==4 so we simply read the status word
      res = regs[AF_RDFD/4];
      //This is the status word. Bits 0-3 TAG, bit 4 - INTERR, bit 5 - DECERR, bit 6 - SLVERR
      //bit 7 - OKAY, bits 30-8 - length of the transfer, bit 31 - EOP
      if((res & (1<<7))==0) {
	printk( KERN_ERR "Incorrect status of AXI_DM status packet, should be OKAY, value is %x\n",res);
	break; //Again - what should be the correct action?
      }
      //Decode the number of the handled buffer
      nbuf = res & 0xf;
      //Here we should verify, that this is an expected buffer
      if(nbuf != exp_buf) {
	printk( KERN_ERR "Incorrect buffer number. Expected: %x, received: %x\n", exp_buf, nbuf);
      }
      //Decode the number of received bytes
      blen[nbuf] = (res & 0x3fffff00) >> 8;
      //Mark the buffer as ready
      bready[nbuf]=1;
      //Update the number of the expected buffer
      exp_buf += 1;
      if(exp_buf == BUF_NUM) exp_buf = 0;
    }    
    //Wake up the reading process
    wake_up_interruptible(&readqueue);
    return IRQ_HANDLED;
  }
  return IRQ_NONE; //Our device does not request interrupt
};


/* Function requesting transfer of the i-th buffer */
static void transfer_buf(int i)
{
  volatile uint32_t * regs;
  uint32_t val;
  regs = (volatile uint32_t *) fmem;
  val = (1<<22)-1 ; //Maximum length of the transfer
  val |= (1<<23);
  val |= (1<<30);
  //Write it to the FIFO
  regs[AF_TDFD/4] = val;
  mb();
  val = phys_buf[i];
  regs[AF_TDFD/4] = val;
  mb();
  val = i;
  regs[AF_TDFD/4] = val;
  mb();
  regs[AF_TLR/4] = 9; //Our command is only 9 bytes long
  mb();
}

/* Cleanup resources */
int tst1_remove(struct platform_device *pdev )
{
  int i;
  if(my_dev && class_my_tst) {
    device_destroy(class_my_tst,my_dev);
  }
  if(fmem) {
    devm_iounmap(&pdev->dev,fmem);
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
  for(i=0;i<BUF_NUM;i++) {
    if(virt_buf[i]) dma_free_coherent(&pdev->dev,BUF_SIZE,virt_buf[i],phys_buf[i]);
    virt_buf[i]=NULL;
    phys_buf[i]=0;
  }
  return 0;
}

long tst1_ioctl(struct file * fd, unsigned int cmd, unsigned long arg) {
  int i, res;
  volatile uint32_t * regs;
  regs = (volatile uint32_t *) fmem;
  switch(cmd) {
  case ADM_RESET:
    //We reset the DataMover - it requires hardware support!
    //OK. It is done via the GPIO. However now I want to control that GPIO myself. Not via the standard driver!
    //bit 0 - reset of the DMA engine
    //bit 1 - start of the data generator
    //WELL I'll do it later! (I have to investigate how to assign the proper GPIO
    //We reset the engines
    ksgpio_set_reset(0);
    ksgpio_set_start(0);
    mdelay(100);
    ksgpio_set_reset(1);
    mdelay(100);
    regs[AF_STR_RESET/4]=0xa5;
    regs[AF_TX_RESET/4]=0xa5;
    regs[AF_RX_RESET/4]=0xa5;
    //wait 1/10 second - shouldn't it be in the user space?
    mdelay(100);
    return SUCCESS;
  case ADM_START:
    //First we check if the transfer is not started yet
    if(is_started) {
      printk(KERN_ERR "Acquisition is already started!\n");
      return -EINVAL;
    }
    //Set the buffer numbers
    exp_buf = 0;
    received_buf = 0;
    //Clear the ready flag in all buffers
    for(i=0;i<BUF_NUM;i++) bready[i]=0;
    //We submit request to transfer all buffers
    for(i=0;i<BUF_NUM;i++) transfer_buf(i);
    //And now we enable the interrupts
    regs[AF_IER/4] = 0x04000000;
    mb();
    ksgpio_set_start(1);
    //We should be able to reset the DataMover - both the engine and the STSCMD part.
    //It should be possible to do it under software control!
    is_started = 1;
    return SUCCESS;
  case ADM_STOP:
    //We simply disable the interrupts
    regs[AF_IER/4] = 0x00000000;
    //Here we stop the transfer. How to do it?
    // 1) We stop resending the descriptors
    // 2) We reset the FIFO
    is_started = 0; 
    return SUCCESS;
  case ADM_GET:
    //We sleep, waiting until the buffer is ready
    res=wait_event_interruptible(readqueue, bready[received_buf] > 0);
    if(res) return res; //Signal received!
    //The buffer is ready to be serviced
    //We return the number of the buffer and the number of available bits
    res = ((received_buf) << 24) | blen[received_buf];
    return res;
    //W tej komendzie powinniśmy oczekiwać na dostępność kolejnego bufora (buforów?)
    //Jeśli bufor jest, to komenda wraca. Powinna być możliwość wysłania z uśpieniem, lub bez.
    //Oprócz tego powinniśmy mieć możliwość korzystania z "poll". Chodzi o to, żeby nie powodować niepotrzebnego
    //mnożenia wątków
    //
    //Jak załatwiamy obsługę błędu "overflow"?
    //Powinniśmy wykrywać problem polegający na tym, że zostały obsłużone wszystkie zlecenia transferu.
    //Oznacza to, że aplikacja nie nadążyła odbierać danych.
  case ADM_CONFIRM:
    //Here we confirm, that we have finished servicing the buffer
    if(bready[received_buf] == 0) return -EINVAL; //Error, the buffer was not ready, we can't confirm it!            
    blen[received_buf] = 0;
    bready[received_buf] = 0;
    transfer_buf(received_buf);
    received_buf += 1;
    if(received_buf == BUF_NUM) received_buf = 0;
    return SUCCESS;
  default:
    return -EINVAL;
  }
}

static int tst1_open(struct inode *inode, 
		     struct file *file)
{
  int res;
  nonseekable_open(inode, file);
  res=request_irq(irq,tst1_irq,IRQF_SHARED,DEVICE_NAME,my_pdev);
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
  //If data acquisition is started, stop it
  if(is_started) {
    volatile uint32_t * regs;
    regs = (volatile uint32_t *) fmem;
    regs[AF_IER/4] = 0x00000000;
    is_started = 0; 
  }
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

int tst1_mmap(struct file *filp,
	      struct vm_area_struct *vma)
{
  unsigned long physical;
  unsigned long vsize;
  unsigned long psize;
  int res;
  unsigned long off = vma->vm_pgoff;    
  if((off < 0) || (off >= BUF_NUM)) return -EINVAL;
  vsize = vma->vm_end - vma->vm_start;
  psize = BUF_SIZE;
  if(vsize>psize)
    return -EINVAL;
  printk(KERN_INFO "Mapping with dma_map_coherent DMA buffer at phys: %p virt %p\n",phys_buf[off],virt_buf[off]);
  vma->vm_pgoff = 0; //We use the offset to pass the number or the buffer!
  res = dma_mmap_coherent(&my_pdev->dev, vma, virt_buf[off], phys_buf[off],  BUF_SIZE);
  return res;
}

static int tst1_probe(struct platform_device *pdev)
{
  int i;
  int res = 0;
  struct resource * resptr = NULL;
  if (my_pdev) {
    //We can't handle more than one device
    printk(KERN_INFO "The driver handles already one device: %p\n", my_pdev);
    return -EINVAL;
  }
  //Check if the GPIO for control of the device is loaded
  res = ksgpio_check_status();
  if(res) {
    printk(KERN_ERR "KSGPIO not initialized properly.\n");
    goto err1;
  }
  resptr = platform_get_resource(pdev,IORESOURCE_MEM,0);
  if(resptr==0) {
    printk(KERN_ERR "Error reading the register addresses.\n");
    res=-EINVAL;
    goto err1;
  }
  phys_addr = resptr->start; 
  phys_len = resptr->end - resptr->start;
  fmem = devm_ioremap_resource(&pdev->dev,resptr);
  if(IS_ERR(fmem)) {
    printk (KERN_ERR "Mapping of memory for %s registers failed\n",
	    DEVICE_NAME);
    res= PTR_ERR(fmem);
    goto err1;
  }
  //Connect the interrupt
  irq = platform_get_irq(pdev,0);
  if(irq<0) {
    printk(KERN_ERR "Error reading the IRQ number: %d.\n",irq);
    res=irq;
    goto err1;
  }
  printk(KERN_INFO "Connected IRQ=%d\n",irq);   
  //Create the class
  class_my_tst = class_create(THIS_MODULE, CLASS_NAME);
  if (IS_ERR(class_my_tst)) {
    printk(KERN_ERR "Error creating my_tst class.\n");
    res=PTR_ERR(class_my_tst);
    goto err1;
  }
  /* Alocate device number */
  res=alloc_chrdev_region(&my_dev, 0, 1, DEVICE_NAME);
  if(res) {
    printk (KERN_ERR "Alocation of the device number for %s failed\n",
	    DEVICE_NAME);
    goto err1; 
  };
  my_cdev = cdev_alloc( );
  if(my_cdev == NULL) {
    printk (KERN_ERR "Allocation of cdev for %s failed\n",
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
  device_create(class_my_tst,NULL,my_dev,NULL,"s2dmov_%d",MINOR(my_dev));
  printk (KERN_INFO "%s The major device number is %d.\n",
	  "Registeration is a success.",
	  MAJOR(my_dev));
  printk(KERN_INFO "Registered device at: %p\n",pdev);
  my_pdev = pdev;
  /* Here we create memory buffers */
  for(i=0;i<BUF_NUM;i++) {
    virt_buf[i] = dma_zalloc_coherent(&pdev->dev, BUF_SIZE, &phys_buf[i],GFP_KERNEL);
    if(virt_buf[i]==NULL) {
      printk ("Allocation of the DMA buffer nr %d failed\n",i);
      goto err1;
    }
    printk(KERN_INFO "DMA buffer phys: %x, virt: %x\n", phys_buf[i], virt_buf[i]);
  }
  //Now let's blink the LED
  //for(i=0;i<10;i++) {
  //   printk (KERN_INFO "SET 0\n");
  //  ksgpio_set_start(0);
  //   ksgpio_set_reset(0);
  //   mdelay(500);
  //   printk (KERN_INFO "SET 1\n");
  //   ksgpio_set_start(1);
  //   ksgpio_set_reset(1);
  //   mdelay(500);
  //}
  return 0;
 err1:
  if (fmem) {
    devm_iounmap(&pdev->dev,fmem);
    fmem = NULL;
  }
  return res;
}

//We connect to the platform device
static struct of_device_id axi4s2dmov_driver_ids[] = {
  {
    .compatible = "xlnx,axi-fifo-mm-s-4.1",
  },
  {},
};

static struct platform_driver my_driver = {
  .driver = { 
    .name = DEVICE_NAME,
    .of_match_table = axi4s2dmov_driver_ids,
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
  printk(KERN_ALERT "Welcome to AXI4S2DMOV\n");
  return platform_driver_register(&my_driver);
}


static void tst1_cleanup_module(void)
{
  printk(KERN_ALERT "AXI4S2DMOV says good-bye\n");
  platform_driver_unregister(&my_driver);
}


module_init(tst1_init_module);
module_exit(tst1_cleanup_module);

