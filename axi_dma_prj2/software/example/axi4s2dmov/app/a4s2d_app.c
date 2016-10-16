#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
//#include "../axi4s2dmov.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <fcntl.h>


const char dev_name[]="/dev/s2dmov_0";

#define BUF_SIZE (4096*1024)

int main(int argc, char * argv[])
{
  int fdev;
  int res;
  int buf_len;
  volatile uint32_t * buf;
  volatile uint32_t * regs;
  uint32_t val,val2, val3;
  int i;
  //Open our device
  fdev=open(dev_name,O_RDWR);
  if(fdev==-1) {
    perror("I can't open the device");
    exit(1);
  }
  //Map the registers
  regs=mmap(0,0x10000,PROT_READ | PROT_WRITE, MAP_SHARED, fdev, 0);
  if (regs==NULL) {
      perror("I can't map registers");
      exit(1);
  }
  //Map the buffer
  buf=mmap(0,0x1000,PROT_READ | PROT_WRITE, MAP_SHARED, fdev,BUF_SIZE);
  val=ioctl(fdev,0x1234,0);
  close(fdev);
  return 0;
}
