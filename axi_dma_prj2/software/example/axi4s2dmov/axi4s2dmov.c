/* Driver for AXI4Stream source connected via AXI DataMover
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
#include <asm/uaccess.h>
#define SUCCESS 0
#define DEVICE_NAME "wzab_axi4s2dmov"
#define CLASS_NAME "class_axi4s2dmov"

#define BUF_SIZE (4096*1024)

//AXI FIFO REGISTERS
#define AF_STR_RESET 0x28
#define AF_TX_RESET 0x8
#define AF_RX_RESET 0x18
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

static void * virt_buf = NULL;
static dma_addr_t phys_buf = 0;
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

/* Cleanup resources */
int tst1_remove(struct platform_device *pdev )
{
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
    if(virt_buf) dma_free_coherent(&pdev->dev,BUF_SIZE,virt_buf,phys_buf);
    virt_buf=NULL;
    phys_buf=0;
    return 0;
}

long tst1_ioctl(struct file * fd, unsigned int cmd, unsigned long arg) {
    uint32_t val,val2, val3;
    int i, j;
    volatile uint32_t * regs;
    regs = (volatile uint32_t *) fmem;
    switch(cmd) {
        case 0x1234:
            printk(KERN_INFO "ioctl 0x1234 called!");
            //Reset the FIFOS
            regs[AF_STR_RESET/4]=0xa5;
            regs[AF_TX_RESET/4]=0xa5;
            regs[AF_RX_RESET/4]=0xa5;
            mb();
            //wait a second
            mdelay(300);
            //Now we program the command for the first transfer
            val = (1<<22)-1 ; //Maximum length of the transfer
            val |= (1<<23);
            val |= (1<<30);
            //Write it to the FIFO
            regs[AF_TDFD/4] = val;
            mb();
            val = phys_buf;
            regs[AF_TDFD/4] = val;
            mb();
            val = 7;
            regs[AF_TDFD/4] = val;
            mb();
            regs[AF_TLR/4] = 9; //Our command is only 9 bytes long
            mb();
            //Now we wait until the transmission is completed
            mdelay(300);
            val=regs[AF_RDFO/4];
            if(val==0) {
                printk(KERN_INFO "Nothing received!\n");
                return 0;
            }
            val2=regs[AF_RLR/4];
            printk(KERN_INFO "RLR=%d\n",val2);
            for(i=0;i<(val2+3)/4;i++) {
                int nbytes;
                uint8_t * bt = (uint8_t *) virt_buf;
                val3=regs[AF_RDFD/4];
                printk( KERN_INFO "DTA=%x\n",val3);
                //Extract the transmitted data
                nbytes = (val3 & 0x7fffff00) >> 8;
                for(j=0;j<nbytes;j++) {
                    printk( KERN_INFO "%x ", (int) *(bt++));
                }
                printk( KERN_INFO "\n");
            }
            return 0;
        default:
            return -EINVAL;
    }
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
    unsigned long off = vma->vm_pgoff;
    
    if((off<0) || (off>1)) return -EINVAL;
    if(off==0) {
        vsize = vma->vm_end - vma->vm_start;
        physical = phys_addr;
        psize = phys_len;
        if(vsize>psize)
            return -EINVAL;
        //Added basing on http://4q8.de/?p=231
        vma->vm_flags |= VM_IO;
        vma->vm_page_prot=pgprot_noncached(vma->vm_page_prot);
        //END
        remap_pfn_range(vma,vma->vm_start, physical >> PAGE_SHIFT , vsize, vma->vm_page_prot);
        if (vma->vm_ops)
            return -EINVAL; //It should never happen
            vma->vm_ops = &tst1_vm_ops;
        tst1_vma_open(vma); //This time no open(vma) was called
        //printk("<1>mmap of registers succeeded!\n");
        return 0;
    } else if(off==1) {
        vsize = vma->vm_end - vma->vm_start;
        physical = phys_buf;
        psize = BUF_SIZE;
        if(vsize>psize)
            return -EINVAL;
        remap_pfn_range(vma,vma->vm_start, physical >> PAGE_SHIFT , vsize, vma->vm_page_prot);
        if (vma->vm_ops)
            return -EINVAL; //It should never happen
            vma->vm_ops = &tst1_vm_ops;
        tst1_vma_open(vma); //This time no open(vma) was called
        return 0;
    }
    return -EINVAL;
}

static int tst1_probe(struct platform_device *pdev)
{
    int res = 0;
    struct resource * resptr = NULL;
    if (my_pdev) {
        //We can't handle more than one device
        printk(KERN_INFO "The driver handles already one device: %p\n", my_pdev);
        return -EINVAL;
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
    /* Now we alloc the memory buffer */
    virt_buf = dma_zalloc_coherent(&pdev->dev, BUF_SIZE, &phys_buf,GFP_KERNEL);
    if(virt_buf==NULL) {
        printk ("Allocation of the DMA buffer failed\n");
        goto err1;
    }
    printk(KERN_INFO "DMA buffer phys: %x, virt: %x\n", phys_buf, virt_buf);
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

