#include <stdio.h>
#include <string.h>
#include <cstdint>
#include <iostream>

void dma1(volatile uint32_t * a, uint32_t count, uint32_t key);
uint32_t tdta[1000];

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
