#define ADM_IOC_MAGIC ('d')
#define ADM_RESET _IO(ADM_IOC_MAGIC, 1)
#define ADM_START _IO(ADM_IOC_MAGIC, 2)
#define ADM_STOP _IO(ADM_IOC_MAGIC, 3)
#define ADM_GET _IO(ADM_IOC_MAGIC, 4)
#define ADM_CONFIRM _IO(ADM_IOC_MAGIC, 5)
#define ADM_IOC_MAXNR (5)

//Number of DMA buffers
#define BUF_NUM 16
//Size of a single DMA buffer
#define BUF_SIZE (4096*1024)
