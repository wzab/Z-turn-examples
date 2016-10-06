
//Buffer descriptor pointer
struct  tst1_buf_desc {
int magic;
void * buf;
int len;
} __attribute__ ((packed));


#define TST1_IOCTL_TYPE 'W'

#define TST1_IOC_MINNR 0x30
// Define commands
#define TST1_IOCTL_MAPBUF _IOW(TST1_IOCTL_TYPE,0x30,struct tst1_buf_desc) // Map the buffer for DMA
#define TST1_IOCTL_UNMAPBUF _IO(TST1_IOCTL_TYPE,0x31) // Unmap the buffer for DMA
#define TST1_IOCTL_START _IO(TST1_IOCTL_TYPE,0x32) // Start the DMA
#define TST1_IOCTL_STOP _IO(TST1_IOCTL_TYPE,0x33) // Stop the DMA

#define TST1_IOC_MAXNR 0x33
#define TST1_MAGIC 0x32abbe57

