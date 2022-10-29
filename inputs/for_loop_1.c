#include <stdint.h>
#include <stdlib.h>

int z = 44;
int arr[10] = {};
int offset = 0;

void func() {
    int arrLen = sizeof(arr)/sizeof(int);
    for (int i = 0; i < arrLen; i ++) {
        if (i == offset) {
            arr[i] = z;
        } else {
            arr[i] = i;
        }
    }
}