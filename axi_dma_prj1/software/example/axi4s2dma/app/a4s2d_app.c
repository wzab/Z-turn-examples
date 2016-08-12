#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "../axi4s2dma.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <fcntl.h>

const char dev_name[]="/dev/s2mm_0";

#define BUF_SIZE 2000

int main(int argc, char * argv[])
{
  int fdev;
  int res;
  int buf_len;
  uint32_t * buf;
  struct tst1_buf_desc bd;
  //Open our device
  fdev=open(dev_name,O_RDWR);
  if(fdev==-1) {
    perror("I can't open the device");
    exit(1);
  }
  //Allocate our buffer
  buf_len=BUF_SIZE*sizeof(uint32_t);
  buf=malloc(buf_len);
  if(!buf) {
    perror("I can't allocate the buffer");
    exit(1);
  }
  printf("Allocated buffer with length %d at %p\n",buf_len,buf);
  //Create the buffer descriptor
  bd.magic = TST1_MAGIC;
  bd.buf = (void *) buf;
  bd.len = buf_len;
  //Now map the buffer
  res = ioctl(fdev,TST1_IOCTL_MAPBUF,(long) &bd);
  if(res<0) {
    perror("I can't map the buffer");
    exit(1);
  }
  printf("Buffer mapped\n");
  //Now start the transfer
  res = ioctl(fdev,TST1_IOCTL_START,0);
  if(res<0) {
    perror("I can't start the transfer");
    exit(1);
  }
  printf("Transfer started\n");
  //Now wait for transfer completion
  res = ioctl(fdev,TST1_IOCTL_STOP,0);
  if(res<0) {
    perror("I can't complete the transfer");
    exit(1);
  }
  printf("Transfer completed\n");
  //Now print the first characters from the buffer
  {
    int i;
    for(i=0;i<100;i++) {
      printf("%4.4d -> %8.8x\n",i,buf[i]);
    }
  }
  res = ioctl(fdev,TST1_IOCTL_UNMAPBUF,0);
  if(res<0) {
    perror("I can't unmap the buffer");
    exit(1);
  }
  printf("Buffer unmapped\n");
  close(fdev);
  return 0;
}
