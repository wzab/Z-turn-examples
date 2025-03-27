#include <stdio.h>
#include <string.h>
#include <cstdint>
#include <iostream>

void dma1(volatile int* a, unsigned long count, uint32_t key);
int tdta[1000];

int main(void)
{
    for(int i=0;i<1000;i++) {
        tdta[i] = i;
    }
    dma1(tdta,500,0x1);
    for(int i=0;i<1000;i++) {
        std::cout << i << "," << tdta[i] << std::endl;
    }
    return 0;
}