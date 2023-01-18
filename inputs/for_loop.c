#include <stdint.h>
#include <stdlib.h>

int z = 3;
int y = 0;
void func(int num) {
    for (int i = 0; i < num; i ++) {
        if (i == z) {
            y = 1;
        }
    }
}

void func2(int num) {
    for (int i = 0; i < num; i ++) {
        if (i != z) {
            y ++;
        }
    }
}

// checkpointed code
static unsigned int heartbeat = 0;
void func3(float* ckpt_mem, int num) {
    for (int i = 0; i < num; i ++) {
        if (i != z) {
            ckpt_mem[0] = heartbeat++;
            ckpt_mem[1] = y;    // store to memory segment
            y ++;
        }
    }
}
