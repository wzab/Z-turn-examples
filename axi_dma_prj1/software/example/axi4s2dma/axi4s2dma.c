/* Quick and dirty driver for testing of simple AXI4 Stream data source
 * connected to the AXI-DMA controller in Zynq system
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
#include <linux/dmaengine.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/sched.h>
#include <linux/mm.h>
#include <linux/slab.h>
#include <linux/io.h>
#include <linux/interrupt.h>
#include <asm/uaccess.h>
#define SUCCESS 0
#define DEVICE_NAME "wzab_axi4s2dma"
#define CLASS_NAME "class_axi4s2dma"
#include "axi4s2dma.h"

//Global variables used to store information about WZAB_BM1
//This must be changed, if we'd like to handle multiple WZAB_BM1 instances

struct dma_chan * a4s2d_chan = NULL;

DECLARE_WAIT_QUEUE_HEAD(tst1_queue);

static int free_user_pages(struct page **page_list, unsigned int nr_pages,
			   int dirty)
{
  unsigned int i;
 
  for (i = 0; i < nr_pages; i++) {
    if (page_list[i] != NULL) {
      if (dirty)
	set_page_dirty_lock(page_list[i]);
      put_page(page_list[i]);
    }
  }
  return 0;
}

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

//int tst1_mmap(struct file *filp, struct vm_area_struct *vma);
long tst1_ioctl(struct file *filp, unsigned int cmd, unsigned long arg);

dev_t my_dev=0;
struct cdev * my_cdev = NULL;
static struct class *class_my_tst = NULL;

struct file_operations Fops = {
  .owner = THIS_MODULE,
  //.read=tst1_read, /* read */
  //.write=tst1_write, /* write */
  .open=tst1_open,
  .release=tst1_release,  /* a.k.a. close */
  .unlocked_ioctl=tst1_ioctl,
  //.llseek=no_llseek,
  //.mmap=tst1_mmap
};

//In the future it will be the structure holding the data private for the particular instance
//Now we have only one structure for one device
struct tst1_ctx_s {
  int nr_pages;
  void * pages;
  struct sg_table sgt;
  int sg_len;
  struct dma_async_tx_descriptor * atx_desc;
  unsigned char is_mapped; 
  unsigned char is_running; 
} ;

struct tst1_ctx_s tst1_ctx = {
  .nr_pages = 0,
  .atx_desc = NULL,
  .pages = NULL,
  .sgt = {
    .sgl = NULL,
    .nents = 0,
    .orig_nents = 0,
  },
  .is_mapped = 0,
  .is_running = 0,
  .sg_len = 0,
};


void a4s2d_callback(void * arg)
{
  struct tst1_ctx_s * p;
  p = (struct tst1_ctx_s *) arg;
  p->is_running = 0;
  printk(KERN_INFO "Hi, I was in callback!");
  wake_up_interruptible(&tst1_queue);
}

void print_sg_table(struct sg_table * sgt)
{
  int i;
  printk(KERN_INFO "SG list nents=%d,orig_nents=%d\n",sgt->nents,sgt->orig_nents);
  for(i=0;i<sgt->orig_nents;i++) {
    struct scatterlist * s = &sgt->sgl[i];
    printk(KERN_INFO "%d, pl=%lx, offs=%x, len=%x, dma=%x\n",i,s->page_link,s->offset,s->length,s->dma_address);
  }
}

long tst1_unmap_buf(void)
{
  struct tst1_ctx_s * p;
  int res=0;
  p=&tst1_ctx; // In the future it will be changed to support multiple instances
  if(!p->is_mapped) return 0; // Buffer was not mapped
  //Unmap the buffer
  dma_unmap_sg(a4s2d_chan->device->dev,p->sgt.sgl,p->sgt.nents, DMA_FROM_DEVICE);
  //Free the table
  sg_free_table(&p->sgt);
  //Free pages - we mark them as dirty
  free_user_pages(p->pages, p->nr_pages,1);
  //Free the "pages" array
  kfree(p->pages);
  p->pages = NULL;
  p->nr_pages = 0;
  //Clear the "is_mapped" flag
  p->is_mapped = false;
  return res;      
}

long tst1_ioctl(struct file *filp, unsigned int cmd, unsigned long arg)
{
  int err = 0;
  long res;
  struct tst1_ctx_s * p;
  //Initial tests
  printk (KERN_INFO "Test TYPE\n");
  if (_IOC_TYPE(cmd) != TST1_IOCTL_TYPE)
    return -ENOTTY;
  printk (KERN_INFO "Test MINNR\n");
  if (_IOC_NR(cmd) < TST1_IOC_MINNR)
    return -ENOTTY;
  printk (KERN_INFO "Test MAXNR\n");
  if (_IOC_NR(cmd) > TST1_IOC_MAXNR)
    return -ENOTTY;
  printk (KERN_INFO "Test READ access\n");
  if (_IOC_DIR(cmd) & _IOC_READ)
    err = !access_ok(VERIFY_WRITE, (void *)arg,_IOC_SIZE(cmd));
  else {
    printk (KERN_INFO "Test WRITE access\n");
    if (_IOC_DIR(cmd) & _IOC_WRITE)
    err = !access_ok(VERIFY_READ, (void *)arg,_IOC_SIZE(cmd));
  }
  if (err) return -EFAULT;
  printk (KERN_INFO "Testing the command number: %x\n", _IOC_NR(cmd));
  res = 0;
  p=&tst1_ctx; // In the future it will be changed to support multiple instances
  switch(cmd) {
  case TST1_IOCTL_MAPBUF:
    //We should have received the buffer descriptor pointer in arg
    {
      struct tst1_buf_desc desc;
      int np, offs;
      unsigned long pbuf;
      //If the buffer is already mapped, return EBUSY
      printk (KERN_INFO "Testing if mapped\n");
      if (p->is_mapped) return -EBUSY;
      printk (KERN_INFO "Copying from user\n");
      if (copy_from_user(&desc,(void *) arg,sizeof(struct tst1_buf_desc))) return -EFAULT;
      printk (KERN_INFO "Testing the magic\n");
      if (desc.magic != TST1_MAGIC ) {
	printk (KERN_ERR "Incorrect MAGIC\n");
	return -EINVAL;
      }
      //OK. Basic tests passed, we can start mapping
      //Code is based on http://lxr.free-electrons.com/source/drivers/misc/genwqe/card_utils.c
      pbuf = (unsigned long)desc.buf;
      offs = offset_in_page(pbuf);
      p->nr_pages = DIV_ROUND_UP(offs + desc.len, PAGE_SIZE);      
      //Allocate the list of pages
      printk (KERN_INFO "Allocating list of pages\n");
      p->pages = kcalloc(p->nr_pages, sizeof(struct page *), GFP_KERNEL);
      if(!p->pages) {
	printk(KERN_ERR "Alloc of page list failed!\n");
	p->nr_pages = 0;
      }
      printk (KERN_INFO "Getting the user pages\n");
      np = get_user_pages_fast(pbuf & PAGE_MASK, p->nr_pages, 1, p->pages);
      if(np < 0)
	goto fail_get_user_pages;
      if(np != p->nr_pages) {
	//Not everything got allocated
	free_user_pages(p->pages, np, 0);
        res = -EFAULT;
        goto fail_get_user_pages;	
      }
      //Build the sg list for pages
      printk (KERN_INFO "Building the SG table\n");
      res=sg_alloc_table_from_pages(&p->sgt,p->pages,p->nr_pages,offs,desc.len,GFP_KERNEL);
      //Now we can map the buffer for our DMA channel
      printk (KERN_INFO "Mapping SG list for DMA\n");
      p->sg_len = dma_map_sg(a4s2d_chan->device->dev,p->sgt.sgl,p->sgt.nents, DMA_FROM_DEVICE);
      print_sg_table(&p->sgt);
      if(p->sg_len == 0){
	//Mapping has failed
	printk(KERN_ERR "Mapping of the buffer has failed!\n");
	res = -ENOMEM;
	goto fail_sg_built;
      }
      //Mark successfull mapping
      p->is_mapped = true;
      return res;
    fail_sg_built:
      if(p->sgt.sgl) {
	sg_free_table(&p->sgt);
      }
    fail_free_user_pages:
      free_user_pages(p->pages, p->nr_pages, 0);
    fail_get_user_pages:
      kfree(p->pages);
      p->pages = NULL;
      p->nr_pages = 0;
      return res;
    }
  case TST1_IOCTL_UNMAPBUF:
    {
      tst1_unmap_buf();
      return res;
    }
  case TST1_IOCTL_START:
    {
      struct dma_slave_config cfg = {
	.direction = DMA_DEV_TO_MEM,
	.src_addr_width = 4,
	.dst_addr_width = 4,
	.src_maxburst = 16,
	.dst_maxburst = 16,
	.device_fc = true,
      };
      //We have the mapped buffer, pass it to the device
      dma_sync_sg_for_device(a4s2d_chan->device->dev,p->sgt.sgl,p->sgt.nents, DMA_FROM_DEVICE);
      //We must set reasonable flags, they are selected from "dma_ctrl_flags"
      printk (KERN_INFO "Preparing the DMA TX descriptor\n");      
      p->atx_desc = dmaengine_prep_slave_sg(a4s2d_chan,p->sgt.sgl,p->sg_len,DMA_DEV_TO_MEM,
					    DMA_PREP_INTERRUPT | DMA_CTRL_ACK);
      if(!p->atx_desc) {
	printk (KERN_INFO "Faild preparation of the DMA TX descriptor\n");      
	return -EFAULT;
      }
      //Now we must set the callback function
      p->atx_desc->callback_param = (void *) p;
      p->atx_desc->callback = a4s2d_callback;
      //Mark transfer as started
      p->is_running = true;
      //Configure the slave
      if(false) {
	// The below didn't work:
	// Failed to configure the slave
	//  I can't start the transfer: Function not implemented
	printk (KERN_INFO "Configuring the slave\n");      
	res = dmaengine_slave_config(a4s2d_chan,&cfg);
	if(res<0) {
	  printk (KERN_INFO "Failed to configure the slave\n");      
	  return res;
	}
      }
      //And finally we submit the descriptor
      printk (KERN_INFO "Submitting the DMA TX descriptor\n");      
      //res=dmaengine_submit(p->atx_desc);
      res=p->atx_desc->tx_submit(p->atx_desc);
      if(res<0) {
	printk (KERN_INFO "Failed submitting the DMA TX descriptor\n");      
	return res;
      }
      dma_async_issue_pending(a4s2d_chan);
      return res;
    }
  case TST1_IOCTL_STOP:
    {
      //We have the mapped buffer, pass it to the device
      //We sleep waiting until transfer is completed
      if(wait_event_interruptible(tst1_queue,! p->is_running)) {
	return -ERESTARTSYS;
      }
      dma_sync_sg_for_cpu(a4s2d_chan->device->dev,p->sgt.sgl,p->sgt.nents, DMA_FROM_DEVICE);
      return res;
    }
  default:
    return -EINVAL;
  }
}
/* Cleanup resources */
int tst1_remove(struct platform_device *pdev )
{
  if(my_dev && class_my_tst) {
    device_destroy(class_my_tst,my_dev);
  }
  if(my_cdev) cdev_del(my_cdev);
  my_cdev=NULL;
  unregister_chrdev_region(my_dev, 1);
  if(class_my_tst) {
    class_destroy(class_my_tst);
    class_my_tst=NULL;
  }
  //printk("<1>drv_tst1 removed!\n");
  return 0;
}

static int tst1_open(struct inode *inode, 
		     struct file *file)
{
  nonseekable_open(inode, file);
  return SUCCESS;
}

static int tst1_release(struct inode *inode, 
			struct file *file)
{
  //Unmap the buffer in case if it was left as mapped
  tst1_unmap_buf();
  return SUCCESS;
}


static bool ax4s2_dma_filter(struct dma_chan *chan, void *filter_param)
{
  //We just print the name of the channel tested
  printk(KERN_ALERT "Testing channel %s in device %s\n",
	 chan->dev->device.kobj.name,
	 chan->device->dev->kobj.name);
  return !strcmp("40400000.dma",chan->device->dev->kobj.name);
}

static int tst1_init_module(void)
{
  int res;
  dma_cap_mask_t mask;
  printk(KERN_ALERT "Welcome to AXI4S2DMA module\n");
  dma_cap_zero(mask);
  dma_cap_set(DMA_SLAVE, mask);  
  // Now  search for our DMA channel
  a4s2d_chan = dma_request_channel(mask,ax4s2_dma_filter,NULL);
  if (a4s2d_chan == NULL) {
    res = -ENODEV;
    goto err1;
  }
  // Now we can register the character device
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
  device_create(class_my_tst,NULL,my_dev,NULL,"s2mm_%d",MINOR(my_dev));
  printk (KERN_INFO "%s The major device number is %d.\n",
	  "Registeration is a success.",
	  MAJOR(my_dev));
  return 0;
 err1:
  return res;
}


static void tst1_cleanup_module(void)
{
  if(a4s2d_chan) dma_release_channel(a4s2d_chan);
  printk(KERN_ALERT "AXIL2IPB bridge says good-bye\n");
  if(class_my_tst && my_cdev) {
    device_destroy(class_my_tst,my_dev);
  }
  if(my_cdev) {
    cdev_del(my_cdev);  
  }
  unregister_chrdev_region(my_dev,1);
  if(class_my_tst) {
    class_destroy(class_my_tst);
  }

}

module_init(tst1_init_module);
module_exit(tst1_cleanup_module);

