#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <stdint.h>
#include "../axi4s2dmov.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/ioctl.h>
#include <fcntl.h>


const char dev_name[]="/dev/s2dmov_0";

volatile uint32_t * buf[BUF_NUM];

int main(int argc, char * argv[])
{
    int fdev;
    int res;
    int i, j, nbuf, nbytes, nwords;
    int buf_len;
    volatile uint32_t * regs;
    uint32_t val,val2, val3;
    //Open our device
    fdev=open(dev_name,O_RDWR);
    if(fdev==-1) {
        perror("I can't open the device");
        exit(1);
    }
    printf("Opened the device\n");
    //Map the buffers
    for(i=0;i<BUF_NUM;i++) {
        buf[i]=mmap(0,BUF_SIZE,PROT_READ | PROT_WRITE, MAP_SHARED, fdev,i*0x1000);
        if(buf[i]==NULL) {
            perror("I can't map buffer");
            printf("buffer nr %d\n",i);
            exit(2);
        }
    }
    printf("Mapped all buffers\n");
    val=ioctl(fdev,ADM_RESET,0);
    if(val<0) {
        perror("ADM_RESET ioctl error");
        exit(3);
    }
    printf("ADM_RESET done\n");
    //Sleep 1 second
    sleep(1);
    val=ioctl(fdev,ADM_START,0);
    if(val<0) {
        perror("ADM_START ioctl error");
        exit(3);
    }
    printf("ADM_START done\n");
    while(1) {
        val = ioctl(fdev,ADM_GET,0);
        if(val<0) {
            perror("ADM_GET ioctl error");
            break;
        }
        printf("ADM_GET done\n");
        nbuf = (val >> 24) & 0xf;
        nbytes = val & 0x3fffff;
        nwords = (nbytes+3)/4;
        printf("received %d bytes in buffer %d\n",nbytes,nbuf);
        for(j=0;j<nwords;j++) {
            printf("%d: \n",j);
            printf("%x\n",buf[nbuf][j]);
        }
        val = ioctl(fdev,ADM_CONFIRM,0);      
        if(val<0) {
            perror("ADM_CONFIRM ioctl error");
            break;
        }
        printf("ADM_CONFIRM done\n");
    }
    val=ioctl(fdev,ADM_STOP,0);
    if(val<0) {
        perror("ADM_START ioctl error");
        exit(3);
    }
    printf("ADM_STOP done\n");
    //Trzeba będzie jeszcze dodać odmapowanie buforów!
    close(fdev);
    return 0;
}
