#include <stdio.h>
#include <string.h>
#include <stdint.h>

#define BLOCK_SIZE 256

void dma1(volatile uint32_t * a, uint32_t count, uint32_t key) {

#pragma HLS INTERFACE m_axi depth = 1024 offset = direct bundle = gmem0 port = a 
#pragma HLS INTERFACE s_axilite port = count bundle = control
#pragma HLS INTERFACE s_axilite port = key bundle = control


    int i;
    uint32_t buff[BLOCK_SIZE];

    // memcpy creates a burst access to memory
    // multiple calls of memcpy cannot be pipelined and will be scheduled
    // sequentially memcpy requires a local buffer to store the results of the
    // memory transaction
    unsigned long todo = count;
    unsigned long offset = 0;
    while(todo) {
        int curlen = BLOCK_SIZE < todo ? BLOCK_SIZE : todo;
        memcpy(buff, (const uint32_t *)(a+offset), curlen * sizeof(uint32_t));
        for (i = 0; i < curlen; i++) {
            buff[i] = i + key;
            //buff[i] = buff[i] ^ key;
        }
        memcpy((uint32_t *)(a+offset), buff, curlen * sizeof(uint32_t));
        todo -= curlen;
        offset += curlen;
    }
}
